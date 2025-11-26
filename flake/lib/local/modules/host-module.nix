{lib, ...}:
with lib; let
  inherit (local) paths;

  userSettingsModule = {
    config,
    name,
    hostcfg,
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
        type = with types; passwdEntry str;
        default = "";
        description = "The user description";
      };

      homeDirectory = mkOption {
        type = with types; either path str;
        default = /home + "/${config.username}";
        description = "The home directory os the user in the host";
        apply = toString;
      };

      hostcfg = mkOption {
        type = types.anything;
        readOnly = true;
        description = "The host configuration of this user";
        default = hostcfg;
      };
    };
  };

  hostCommonOptionsModule = {
    config,
    name,
    hostValues,
    ...
  }: let
    hostBasePath = attrByPath ["hostBasePath"] paths.hosts.host hostValues;
  in {
    options = {
      path = mkOption {
        type = types.path;
        default = attrByPath ["path"] (hostBasePath + "/${config.host}") hostValues;
        readOnly = true;
        internal = true;
        description = "The physical path of this host in disk";
      };

      host = mkOption {
        type = types.str;
        default = attrByPath ["host"] name hostValues;
        readOnly = true;
        internal = true;
        description = "The host is the name of its physical path in disk";
      };
    };
  };

  tagRulesModule = {config, ...}: {
    options = {
      enable =
        mkEnableOption "Whether this tag rule should be enabled"
        // {
          default = true;
        };
      description = mkOption {
        type = types.str;
        description = "A clear decription of this rule";
      };
      predicate =
        mkEnableOption "The the predicate that will test the host configuration"
        // {
          default = config.enable;
        };
      tags = mkOption {
        type = with types; addCheck (listOf str) (tags: length tags > 0);
        description = "The list of tags that will be concatenated to the final one, case the predicate evaluates to true";
      };
    };
  };

  sharedHostcfgModule = {
    config,
    parent,
    ...
  }: let
    isVariant = parent != null;
  in {
    options = {
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
        description = "Describes the runtime hardware or virtualization environment";
      };

      sops = mkOption {
        type = types.submoduleWith {
          modules = [
            hostCommonOptionsModule
            {
              options = {
                enable =
                  mkEnableOption "Whether sops should be enabled on this host"
                  // {
                    readOnly = true;
                    default = !config.info.isIso;
                  };
              };
            }
          ];
          specialArgs = {
            hostValues =
              if config.isVariant
              then {inherit (parent) host path;}
              else {inherit (config) host path;};
          };
        };
        default = {};
        description = "Variant parent host configuration";
      };

      tags = mkOption {
        type = with types; listOf str;
        description = "A configurable list of tags for the host";
      };

      tagsFinal = mkOption {
        type = with types; listOf str;
        description = "The final list of tags for the host, including user configured and calculated by rules";
        readOnly = true;
        internal = true;
        default = let
          calculatedTags = pipe config.tagRules [
            attrValues
            (filter (r: r.enable && r.predicate))
            (map (r: r.tags))
            flatten
          ];
          configuredTags = config.tags;
        in
          configuredTags ++ calculatedTags;
      };

      tagRules = mkOption {
        type = with types; attrsOf (submodule tagRulesModule);
        description = "The derivated tag rules";
        default = {
          addRuntimePlatform = {
            description = "Whether to add the host runtime platform to the final list of tags";
            tags = [config.runtimePlatform];
          };
          deriveGraphicalTag = {
            description = ''
              Whether to add a `graphical` tag to the final list of tags if the host:
                . has tag `desktop` or `workstation`
                . runtimePlatform is `wsl`
            '';
            predicate = with config; any (flip elem ["desktop" "workstation"]) tags || runtimePlatform == "wsl";
            tags = ["graphical"];
          };
        };
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
                  parent
                  ;
                inherit
                  (config)
                  host
                  hostname
                  info
                  isVariant
                  sops
                  system
                  tagsFinal
                  ;
                inheritParentConfiguration = config.isVariant && config.inheritParentConfiguration;
                inheritTags = config.isVariant && config.inheritTags;
                inheritTagsConfigurations = config.isVariant && config.inheritTagsConfigurations;
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
          default = isVariant;
        };

      info = mkOption {
        type = types.anything;
        readOnly = true;
        description = "Several keys that provide information about this host";
        default = {
          hasAnyTagIn = searchTags: any (flip elem searchTags) config.tagsFinal;
          hasAllTagsIn = searchTags: all (flip elem searchTags) config.tagsFinal;
          hasTag = flip elem config.tags;
          isBareMetal = config.runtimePlatform == "bare-metal";
          isIso = config.runtimePlatform == "iso";
          isTv = config.runtimePlatform == "tv";
          isVirtualMachine = config.runtimePlatform == "virtual-machine";
          isWsl = config.runtimePlatform == "wsl";
          runtimePlatformIsOneOf = any (platform: config.runtimePlatform == platform);
        };
      };
    };

    config = {
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
      parent = mkOption {
        type = types.submoduleWith {
          modules = [
            hostCommonOptionsModule
          ];
          specialArgs = {
            hostValues = {inherit (parent) host path;};
          };
        };
        default = {};
        description = "Variant parent host configuration";
      };

      inheritParentConfiguration =
        mkEnableOption "Whether to inherit the base configuration from parent host"
        // {
          default = true;
        };
      inheritTags =
        mkEnableOption "Whether to inherit tags from parent hostcfg"
        // {
          default = true;
        };
      inheritTagsConfigurations =
        mkEnableOption "Whether to inherit tags configurations from parent hostcfg"
        // {
          default = config.inheritTags;
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
      # tags = mkIf config.inheritTags (filter (tag: tag != parent.runtimePlatform) parent.tags);
      tagRules.inheritParentTags = {
        description = "Wheter to inherit parent configured tags";
        predicate = mkForce config.inheritTags;
        inherit (parent) tags;
      };
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

  parentHostcfgModule = {config, ...}: let
    variantsBasePath = config.path + "/variants";
  in {
    options = {
      variants = mkOption {
        type = with types;
          attrsOf (submoduleWith {
            modules = [
              hostCommonOptionsModule
              sharedHostcfgModule
              variantHostcfgModule
            ];
            specialArgs = {
              hostValues = {
                hostBasePath = variantsBasePath;
              };
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
          hostCommonOptionsModule
          sharedHostcfgModule
          parentHostcfgModule
        ];
        specialArgs = {
          hostValues = {};
          parent = null;
        };
      });
    default = {};
    description = "All pre-evaluated host configurations derived from ${paths.hosts.host} directory";
  };
}
