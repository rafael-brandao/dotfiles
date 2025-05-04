{
  flakeArgs,
  lib,
  ...
} @ args: let
  inherit
    (builtins)
    attrNames
    baseNameOf
    foldl'
    toString
    ;
  inherit
    (lib)
    anyMatch
    evalModules
    flip
    flipPipe
    forEach
    listDirs
    mapAttrs
    mkMerge
    pipe
    removeAttrs
    updateManyAttrsByPath
    ;
  inherit
    (lib.local)
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
      scripts = flake.dir + /scripts;
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

  inlinedHosts = let
    foldFn = acc: host:
      acc
      // {
        "${host}" = removeAttrs evaluatedHosts.${host} ["variants"];
      }
      // evaluatedHosts.${host}.variants or {};
  in
    foldl' foldFn {} (attrNames evaluatedHosts);

  getHostcfg = flipPipe [
    (flip removeAttrs ["modules"])
    (updateManyAttrsByPath [
      {
        path = ["userSettings"];
        update = mapAttrs (_: flip removeAttrs ["standaloneHomeModules"]);
      }
    ])
  ];

  mkNixosSystem = hostModule: let
    systemConfig = {
      inherit (hostModule) modules system;
      specialArgs = {
        inherit (flakeArgs) inputs outputs;
        inherit paths;
        hostcfg = getHostcfg hostModule;
        osConfig = {};
      };
    };
  in {};
in {
  inherit
    paths
    evaluatedHosts
    inlinedHosts
    getHostcfg
    ;
}
