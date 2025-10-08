{
  flakeArgs,
  lib,
  ...
} @ args: let
  inherit
    (builtins)
    attrNames
    attrValues
    baseNameOf
    getAttr
    filter
    foldl'
    toString
    ;
  inherit
    (flakeArgs)
    inputs
    ;
  inherit
    (inputs.self)
    pkgsFor
    ;
  inherit
    (lib)
    anyMatch
    concatLists
    evalModules
    flatten
    flipPipe
    forEach
    homeManagerConfiguration
    listDirs
    mapAttrs
    mapAttrsToList
    mkMerge
    nixosSystem
    pipe
    removeAttrs
    ;
  inherit
    (lib.local)
    crossValidConfigurationPaths
    indexAttrListFromPath
    isFile
    ;

  getParentPathUntil = filterPathFn: let
    isRootPath = path: toString path == "/";
    go = path:
      if anyMatch [filterPathFn isRootPath] path
      then path
      else go (dirOf path);
  in
    go ./.;

  paths = rec {
    project = getParentPathUntil (dir: isFile (dir + /flake.nix));
    flake = {
      dir = project + /flake;
      overlays = flake.dir + /overlays;
    };
    hosts = {
      dir = project + /hosts;
      host = hosts.dir + /host;
      tags = hosts.dir + /tags;
      shared = hosts.dir + /shared;
    };
    users = {
      dir = project + /users;
      shared = {
        dir = users.dir + /shared;
        home = users.shared.dir + /home;
        nixos = users.shared.dir + /nixos;
      };
      user = users.dir + /user;
    };
    modules = {
      dir = project + /modules;
      common = modules.dir + /common;
      nixos = modules.dir + /nixos;
      home = modules.dir + /home;
    };
    shared = {
      dir = project + /shared;
      tags = shared.dir + /tags;
    };
    scripts = project + /scripts;
  };

  evaluatedHosts = let
    project.submodules = import ./modules/host-module.nix args;
    hostsPath = paths.hosts.host;
    hosts = pipe hostsPath [
      listDirs
      (map baseNameOf)
    ];
    evaluatedModules = evalModules {
      modules = [
        {
          options.project.hostcfg = project.submodules.hostcfgOption;

          config.project.hostcfg = mkMerge (forEach hosts (
            host: {
              "${host}" = import (hostsPath + "/${host}/hostcfg.nix");
            }
          ));
        }
      ];
    };
  in
    evaluatedModules.config.project.hostcfg;

  hostcfgs = let
    foldFn = acc: host:
      acc
      // {
        "${host}" = removeAttrs evaluatedHosts.${host} ["variants"];
      }
      // evaluatedHosts.${host}.variants or {};
  in
    foldl' foldFn {} (attrNames evaluatedHosts);

  usercfgs = pipe hostcfgs [
    (mapAttrsToList (_: flipPipe [(getAttr "userSettings") attrValues]))
    flatten
    (indexAttrListFromPath ["identifier"])
  ];

  getHostModules = hostcfg:
    if !hostcfg.isNixos
    then []
    else let
      coreModules = let
        fromInputs = with inputs; [
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          stylix.nixosModules.stylix
        ];
        fromPaths = with paths; [
          modules.common
          modules.nixos
          shared.dir
          "${hosts.shared}/configuration.nix"
          "${hostcfg.path}/configuration.nix"
          {
            config.lib = {
              build = {
                isNixos = true;
                isHomeManager = false;
                isNixosUser = false;
                isStandaloneUser = false;
              };
            };
          }
        ];
      in
        fromInputs ++ fromPaths;

      modulesFromTags = crossValidConfigurationPaths {
        dirNames = hostcfg.tags;
        baseDirs = with paths; [
          shared.tags
          hosts.tags
          "${hostcfg.path}/tags"
        ];
      };
      modulesFromRules = let
        filterRules = [
          {
            comment = "Rule for hosts which runtime platform is not in group ['iso' 'wsl']";
            predicate =
              !hostcfg.info.runtimePlatformIsOneOf [
                "iso"
                "wsl"
              ];
            modules = with inputs; [
              disko.nixosModules.disko
              nixos-facter-modules.nixosModules.facter
              "${hostcfg.path}/disk-configuration.nix"
              {
                facter.reportPath = "${hostcfg.path}/facter.json";
              }
            ];
          }
          {
            comment = "Rule for hosts that are variants and inherit parent configuration";
            predicate = hostcfg.isVariant && hostcfg.inheritParentConfiguration;
            modules = [
              "${hostcfg.parent.path}/configuration.nix"
            ];
          }
        ];
      in
        pipe filterRules [
          (filter (getAttr "predicate"))
          (map (getAttr "modules"))
          concatLists
        ];
    in
      coreModules ++ modulesFromTags ++ modulesFromRules;

  getUserHomeModules = usercfg: let
    coreModules = let
      fromInputs = with inputs; [
        nixvim.homeModules.nixvim
        sops-nix.homeManagerModules.sops
      ];
      fromPaths = with paths; [
        modules.common
        modules.home
        shared.dir
      ];
      fromUser = with paths; [
        "${users.shared.home}/core/configuration.nix"
        "${usercfg.path}/home/hosts/shared/configuration.nix"
        "${usercfg.path}/home/core/configuration.nix"
        ({osConfig ? {}, ...}: {
          config.lib = {
            build = rec {
              isNixos = false;
              isHomeManager = true;
              isNixosUser = ! isStandaloneUser;
              isStandaloneUser = osConfig == {};
            };
            inherit usercfg;
          };
        })
      ];
    in
      fromInputs ++ fromPaths ++ fromUser;

    optionalModules = let
      fromHost = crossValidConfigurationPaths {
        dirNames = [usercfg.hostcfg.host];
        baseDirs = [
          "${usercfg.path}/home/hosts"
        ];
      };
      fromTags = crossValidConfigurationPaths {
        dirNames = usercfg.hostcfg.tags;
        baseDirs = with paths; [
          shared.tags
          "${users.shared.home}/tags"
          "${usercfg.path}/home/tags"
          "${usercfg.path}/home/hosts/${usercfg.hostcfg.host}/tags"
        ];
      };
    in
      fromHost ++ fromTags;
  in
    coreModules ++ optionalModules;

  getUserStandaloneHomeModules = usercfg:
    (getUserHomeModules usercfg)
    ++ (with inputs; [
      stylix.homeModules.stylix
    ]);

  mkNixosSystem = hostcfg:
    nixosSystem {
      inherit (hostcfg) system;
      modules = getHostModules hostcfg;
      specialArgs = {
        inherit hostcfg inputs lib paths;
        osConfig = {};
      };
    };

  mkHomeConfig = usercfg:
    homeManagerConfiguration {
      extraSpecialArgs = {
        inherit (usercfg) hostcfg;
        inherit inputs lib paths;
        osConfig = {};
      };
      pkgs = pkgsFor usercfg.hostcfg.system;
      modules = getUserStandaloneHomeModules usercfg;
    };

  nixosConfigurations = mapAttrs (_: mkNixosSystem) hostcfgs;

  homeConfigurations = mapAttrs (_: mkHomeConfig) usercfgs;
in {
  inherit
    paths
    hostcfgs
    usercfgs
    nixosConfigurations
    homeConfigurations
    getHostModules
    getUserHomeModules
    getUserStandaloneHomeModules
    ;
}
