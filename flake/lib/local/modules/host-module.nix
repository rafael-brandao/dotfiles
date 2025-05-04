{
  flakeArgs,
  lib,
  ...
}:
with lib; let
  inherit (flakeArgs) inputs;
  inherit (local) crossValidConfigurationPaths paths;

  userSettingsModule = {
    config,
    name,
    hostcfg,
    paths,
    ...
  }: {
    options = {
      user = mkOption {
        type = types.str;
        default = name;
        readOnly = true;
        description = "The user";
      };

      path = mkOption {
        type = types.path;
        default = paths.users.user + "/${config.user}";
        readOnly = true;
        description = "The path of this user in the project";
      };

      username = mkOption {
        type = types.str;
        default = name;
        description = "The username of the user";
      };

      identifier = mkOption {
        type = types.str;
        readOnly = true;
        default = "${config.username}@${hostcfg.hostname}";
        description = "The user identifier: username@hostname";
      };

      description = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "The user description";
      };

      homeDirectory = mkOption {
        type = with types; either path str;
        default = /home + "/${config.username}";
        description = "The home directory os the user in the host";
        apply = toString;
      };

      homeModules = mkOption {
        # type = with types; listOf anything;
        type = with types; listOf deferredModule;
        readOnly = true;
        # internal = true;
        description = "The modules that will be included in the user Home-Manager configuration for NixOS";
        default = let
          coreModules = let
            fromInputs = with inputs; [
              sops-nix.homeManagerModules.sops
            ];
            fromPaths = with paths; [
              modules.common
              modules.home
              shared.dir
            ];
            fromUser = with paths; [
              "${users.shared.home}/core/configuration.nix"
              "${config.path}/home/hosts/shared/configuration.nix"
              "${config.path}/home/core/configuration.nix"
              {
                config.lib.usercfg = {
                  inherit
                    (config)
                    description
                    homeDirectory
                    identifier
                    path
                    user
                    username
                    ;
                };
              }
            ];
          in
            fromInputs ++ fromPaths ++ fromUser;

          optionalModules = let
            fromHost = crossValidConfigurationPaths {
              dirNames = [hostcfg.host];
              baseDirs = [
                "${config.path}/home/hosts"
              ];
            };
            fromTags = crossValidConfigurationPaths {
              dirNames = hostcfg.tags;
              baseDirs = with paths; [
                shared.tags
                "${users.shared.home}/tags"
                "${config.path}/home/tags"
                "${config.path}/home/hosts/${hostcfg.host}/tags"
              ];
            };
          in
            fromHost ++ fromTags;
        in
          coreModules ++ optionalModules;
      };

      standaloneHomeModules = mkOption {
        # type = with types; listOf anything;
        type = with types; listOf deferredModule;
        readOnly = true;
        # internal = true;
        description = "The modules that will be included in the user standalone Home-Manager configuration";
        default =
          config.homeModules
          ++ (with inputs; [
            stylix.homeManagerModules.stylix
          ]);
      };
    };
  };

  sharedHostcfgModule = {
    hostsBasePath,
    parent,
    paths,
    config,
    name,
    ...
  }: {
    options = {
      path = mkOption {
        type = types.path;
        default = hostsBasePath + "/${name}";
        readOnly = true;
        internal = true;
        description = "The physical path of this host in disk";
      };

      host = mkOption {
        type = types.str;
        default = name;
        readOnly = true;
        internal = true;
        description = "The host is the name of its physical path in disk";
      };

      hostname = mkOption {
        type = types.str;
        default = config.host;
        description = "The hostname of this host";
      };

      system = mkOption {
        type = types.str;
        description = "The system of this host";
        example = "x86_64-linux";
      };

      runtimePlatform = mkOption {
        type = with types;
          enum [
            "bare-metal"
            "iso"
            "tv"
            "virtual-machine"
            "wsl"
          ];
        description = "Describes the runtime hardware or virtualization environment.";
      };

      tags = mkOption {
        type = with types; listOf str;
        description = "A list of tags for the host";
      };

      users = mkOption {
        type = with types; listOf str;
        default = [];
        description = "The users of the host";
      };

      userSettings = mkOption {
        type = with types;
          attrsOf (submoduleWith {
            modules = [userSettingsModule];
            specialArgs = {
              inherit paths;
              hostcfg = {
                inherit
                  (config)
                  host
                  hostname
                  tags
                  ;
              };
            };
          });
        default = {};
        description = "Override user settings in case of necessity";
      };

      addRuntimePlatformToTags =
        mkEnableOption "Whether to add the runtime platform to the tags option"
        // {
          default = true;
        };

      isNixos =
        mkEnableOption "Whether this is a NixOS host configuration or not"
        // {
          default = true;
        };

      isVariant =
        mkEnableOption "Whether this is a variant host configuration or not"
        // {
          readOnly = true;
          default = parent != null;
        };

      info = mkOption {
        type = types.anything;
        readOnly = true;
        description = "Several keys that provide information about this host";
        default = {
          hasAnyTagIn = searchTags: any (flip elem searchTags) config.tags;
          hasAllTagsIn = searchTags: all (flip elem searchTags) config.tags;
          hasTag = flip elem config.tags;
          isBareMetal = config.runtimePlatform == "bare-metal";
          isIso = config.runtimePlatform == "iso";
          isTv = config.runtimePlatform == "tv";
          isVirtualMachine = config.runtimePlatform == "virtual-machine";
          isWsl = config.runtimePlatform == "wsl";
          runtimePlatformIsOneOf = any (platform: config.runtimePlatform == platform);
        };
      };

      modules = mkOption {
        # type = with types; listOf anything;
        type = with types; listOf deferredModule;
        readOnly = true;
        # internal = true;
        description = "The modules that will be included in the final Nixos configuration";
        default =
          if !config.isNixos
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
                "${config.path}/configuration.nix"
              ];
            in
              fromInputs ++ fromPaths;

            optionalModules = let
              modulesFromTags = crossValidConfigurationPaths {
                dirNames = config.tags;
                baseDirs = with paths; [
                  shared.tags
                  "${hosts.tags}"
                  "${config.path}/tags"
                ];
              };
              modulesFromRules = let
                filterRules = [
                  {
                    comment = "Rule for hosts which runtime platform is not in group ['iso' 'wsl']";
                    predicate =
                      !config.info.runtimePlatformIsOneOf [
                        "iso"
                        "wsl"
                      ];
                    modules = with inputs; [
                      disko.nixosModules.disko
                      nixos-facter-modules.nixosModules.facter
                      "${config.path}/disk-configuration.nix"
                      {
                        facter.reportPath = "${config.path}/facter.json";
                      }
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
              modulesFromTags ++ modulesFromRules;
          in
            coreModules ++ optionalModules;
      };
    };

    config = {
      tags = mkMerge [
        (mkIf config.addRuntimePlatformToTags [config.runtimePlatform])
        (mkIf (!config.addRuntimePlatformToTags) [])
      ];
      userSettings = mkMerge (
        forEach config.users (user: {
          "${user}" = {};
        })
      );
    };
  };

  variantHostcfgModule = {
    parent,
    config,
    ...
  }: {
    options = {
      inheritTags =
        mkEnableOption "Whether to inherit tags from parent hostcfg"
        // {
          default = true;
        };

      inheritUsers =
        mkEnableOption "Whether to inherit users from parent hostcfg"
        // {
          default = true;
        };
    };
    config = {
      isNixos = mkDefault parent.isNixos;
      runtimePlatform = mkDefault parent.runtimePlatform;
      system = mkDefault parent.system;
      tags = mkIf config.inheritTags (filter (tag: tag != parent.runtimePlatform) parent.tags);
      users = mkIf config.inheritUsers parent.users;
      userSettings = mkIf config.inheritUsers (
        pipe config.users [
          (filter (flip elem parent.users)) # filter only users present in the parent config
          (map (user: {
            "${user}" = {
              description = mkDefault parent.userSettings."${user}".description;
              username = mkDefault parent.userSettings."${user}".username;
            };
          }))
          mkMerge
        ]
      );
    };
  };

  hostcfgModule = {
    paths,
    config,
    ...
  }: let
    variantsBasePath = config.path + "/variants";
  in {
    options = {
      variants = mkOption {
        type = with types;
          attrsOf (submoduleWith {
            modules = [
              sharedHostcfgModule
              variantHostcfgModule
            ];
            specialArgs = {
              inherit paths;
              hostsBasePath = variantsBasePath;
              parent = {
                inherit
                  (config)
                  host
                  hostname
                  isNixos
                  path
                  system
                  runtimePlatform
                  tags
                  users
                  userSettings
                  ;
              };
            };
          });
        default = {};
        description = "All pre-evaluated host variant configurations";
      };
    };
    config = {
      variants =
        if (!pathExists variantsBasePath)
        then {}
        else
          pipe variantsBasePath [
            listDirs
            (filter (variantPath: pathExists (variantPath + "/hostcfg.nix")))
            (map (variantPath: {
              "${baseNameOf variantPath}" = import (variantPath + "/hostcfg.nix");
            }))
            mkMerge
          ];
    };
  };
in {
  hostcfgOption = mkOption {
    type = with types;
      attrsOf (submoduleWith {
        modules = [
          sharedHostcfgModule
          hostcfgModule
        ];
        specialArgs = {
          inherit paths;
          hostsBasePath = paths.hosts.host;
          parent = null;
        };
      });
    default = {};
    description = "All pre-evaluated host configurations derived from ${paths.hosts.host} directory";
  };
}
