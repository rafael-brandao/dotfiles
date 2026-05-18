{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.rb.defaults;

  inherit (local) chainPredicateAttrs negatePredicateAttrs;

  commonSubmodule = {
    config,
    name,
    searchPath,
    ...
  }: let
    path = "${mkString {sep = ".";} searchPath}.${name}";
    umbrellaGroup = head searchPath;
    type =
      if umbrellaGroup == "apps"
      then "app"
      else umbrellaGroup;
  in {
    options = {
      enable =
        mkEnableOption "Whether the ${path} should be enabled."
        // {
          default = config.command != null;
          readOnly = true;
        };
      type = mkOption {
        type = with types; enum ["app" "core"];
        default = type;
        readOnly = true;
        description = "The type that defines this command. One of [app, core].";
      };
      command = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "The default command to launch the ${path}.";
      };
      keyBindings = mkOption {
        type = with types; listOf str;
        default = [];
        description = "The list of key bindings associated with the default ${path} command.";
      };
    };
  };

  commonAppSettingsSubmodule = {
    options = {
      home = {
        autoEnableProgram =
          mkEnableOption "Whether to automatically enable the corresponding home-manager program if it exists.";
        installPackage =
          mkEnableOption "Whether to automatically install the app package in home.packages.";
      };
      xdgMime = {
        autoRegisterPackage =
          mkEnableOption "Whether to automatically register the app package with xdg.mimeApps.defaultApplicationPackages.";
      };
    };
  };

  coreSubmodule = {
    options = {
      requireShell =
        mkEnableOption "Whether this command requires being executed from within a shell.";
    };
  };

  mkCoreGroupOption = group:
    mkOption {
      type = with types;
        attrsOf (submoduleWith {
          modules = [
            commonSubmodule
            coreSubmodule
          ];
          specialArgs = {
            searchPath = ["core" group];
          };
        });
      description = "Default commands for core ${group} group.";
      default = {};
    };

  appSubmodule = {
    config,
    name,
    globalSettings,
    ...
  }: {
    options = {
      args = mkOption {
        type = with types; listOf str;
        default = [];
        apply = mkString {sep = " ";};
        description = "Additional arguments to pass to the default ${name} app.";
      };

      finalCommand = mkOption {
        type = with types; nullOr str;
        readOnly = true;
        default =
          if config.enable
          then trim "${config.command} ${config.args}"
          else null;
      };

      isTui = mkEnableOption "Whether the default ${name} app is a terminal based one or not.";

      envVars = mkOption {
        type = with types; listOf str;
        default = [];
        description = "The list of environment variables that will be defined for the default ${name} app.";
      };

      desktopFileId = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "Desktop file ID for the default ${name}.";
      };

      package = mkOption {
        type = with types; nullOr package;
        default = null;
        description = "The package providing the default ${name} app.";
      };

      name = mkOption {
        type = with types; nullOr str;
        default = null;
        description = "The name of the program in config.programs that corresponds to this app.";
      };

      settings = mkOption {
        type = types.submoduleWith {
          modules = [
            commonAppSettingsSubmodule
            {
              options = {
                xdgMime = {
                  priority = mkOption {
                    type = types.enum ["high" "default" "low"];
                    default = "default";
                    description = ''
                      The priority of the app in xdg.mimeApps.defaultApplicationPackages.
                      High priority apps are listed first, low priority apps are listed last.
                    '';
                  };
                };
              };
            }
          ];
        };
        default = {};
        description = "Per-app settings for the default ${name} app.";
      };
    };

    config = mkMerge [
      {
        command = mkOverride 1490 config.name;
        settings = {
          home = {
            autoEnableProgram = mkOverride 1490 globalSettings.home.autoEnableProgram;
            installPackage = mkOverride 1490 globalSettings.home.installPackage;
          };
          xdgMime.autoRegisterPackage = mkOverride 1490 globalSettings.xdgMime.autoRegisterPackage;
        };
      }
      (mkIf (config.name != null) {
        package = mkOverride 1490 (pkgs.${config.name} or null);
      })
      (mkIf config.isTui {
        settings.xdgMime.priority = mkOverride 1490 "low";
      })
    ];
  };

  appType = with types;
    attrsOf (
      submoduleWith {
        modules = [
          commonSubmodule
          appSubmodule
        ];
        specialArgs = {
          globalSettings = cfg.settings.apps;
          searchPath = ["apps"];
        };
      }
    );

  priorityWeight = priority:
    if priority == "high"
    then 0
    else if priority == "default"
    then 1
    else 2;

  xdgMimeApps = pipe cfg.apps [
    (filterAttrs (
      _name: app:
        app.enable
        && app.package != null
        && app.settings.xdgMime.autoRegisterPackage
    ))
    (mapAttrsToList (_name: app: {
      inherit (app) package;
      weight = priorityWeight app.settings.xdgMime.priority;
    }))
    (sort (a: b: a.weight < b.weight))
    (map (x: x.package))
  ];
in {
  options.rb.defaults = {
    settings = {
      apps = mkOption {
        type = types.submodule commonAppSettingsSubmodule;
        default = {};
        description = "Global settings applied to all default apps.";
      };
    };

    apps = mkOption {
      type = appType;
      description = "Default apps";
      default = {};
    };

    core = {
      audio = mkCoreGroupOption "audio";
      brightness = mkCoreGroupOption "brightness";
      session = mkCoreGroupOption "session";
      shell = mkCoreGroupOption "shell";
    };
  };

  config = let
    isAppInstallable = _name: app:
      app.settings.home.installPackage
      && app.enable
      && app.package != null;

    isAppProgramManaged = _name: app:
      app.settings.home.autoEnableProgram
      && app.enable
      && app.name != null
      && hasAttr app.name config.programs;

    isAppNotProgramManaged = negatePredicateAttrs isAppProgramManaged;
  in {
    home = {
      packages = pipe cfg.apps [
        (filterAttrs (chainPredicateAttrs [
          isAppInstallable
          isAppNotProgramManaged
        ]))
        (mapAttrsToList (_name: app: app.package))
      ];

      sessionVariables = let
        filterFn = filterAttrs (_name: app: app.enable);
        mapFn = app: map (envVar: nameValuePair envVar app.command) app.envVars;
        foldFn = foldlAttrs (acc: _name: flipPipe [mapFn listToAttrs (mergeAttrs acc)]) {};
      in
        pipe cfg.apps [
          filterFn
          foldFn
        ];
    };

    programs = pipe cfg.apps [
      (filterAttrs isAppProgramManaged)
      (mapAttrs' (
        _name: app:
          nameValuePair app.name (
            {enable = mkOverride 1490 true;}
            // (
              if app.package != null && hasAttr "package" config.programs.${app.name}
              then {package = mkOverride 1490 app.package;}
              else {}
            )
          )
      ))
    ];

    xdg.mimeApps.defaultApplicationPackages =
      mkIf config.xdg.mimeApps.enable xdgMimeApps;
  };
}
