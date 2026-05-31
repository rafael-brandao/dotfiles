{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.dank-material-shell;
in
  mkMerge [
    {
      programs.dank-material-shell = mkIf cfg.enable {
        package = mkDefault pkgs.dms;
        quickshell.package = mkDefault pkgs.quickshell;
        systemd = {
          enable = mkDefault true;
          restartIfChanged = mkDefault true;
        };

        # Core features
        enableAudioWavelength = mkDefault true; #   Audio visualizer (cava)
        enableCalendarEvents = mkDefault true; #    Calendar integration (khal)
        enableDynamicTheming = mkDefault true; #    Wallpaper-based theming (matugen)
        enableSystemMonitoring = mkDefault true; #  System monitoring widgets (dgop)
        enableVPN = mkDefault true; #               VPN management widget

        session = mkMerge [
          (mkIf (attrByPath ["services" "sunshine" "enable"] false osConfig) {
            hiddenTrayIds = ["tray-id"];
          })
        ];

        settings = {
          barConfigs = [
            {
              id = "default";
              name = "Main Bar";
              enabled = true;
              position = 0;
              screenPreferences = [
                "all"
              ];
              showOnLastDisplay = true;

              leftWidgets = [
                "launcherButton"
                "layout"
                "workspaceSwitcher"
                "focusedWindow"
              ];

              centerWidgets = [
                "music"
                "clock"
                "weather"
              ];

              rightWidgets = [
                "systemTray"
                "clipboard"
                "cpuUsage"
                "memUsage"
                "notificationButton"
                "battery"
                "controlCenterButton"
              ];

              spacing = 4;
              innerPadding = 4;
              bottomGap = 0;
              transparency = 0;
              widgetTransparency = 1;

              squareCorners = false;
              noBackground = false;

              gothCornersEnabled = false;
              gothCornerRadiusOverride = false;
              gothCornerRadiusValue = 12;

              borderEnabled = false;
              borderColor = "surfaceText";
              borderOpacity = 1;
              borderThickness = 1;

              fontScale = 1;

              autoHide = false;
              autoHideDelay = 250;

              openOnOverview = false;
              visible = true;

              popupGapsAuto = true;
              popupGapsManual = 4;
            }
          ];
          clockDateFormat = "dddd, MMMM d";
          controlCenterWidgets = [
            {
              id = "volumeSlider";
              enabled = true;
            }
            {
              id = "brightnessSlider";
              enabled = true;
            }
            {
              id = "wifi";
              enabled = true;
            }
            {
              id = "bluetooth";
              enabled = true;
            }
            {
              id = "audioOutput";
              enabled = true;
            }
            {
              id = "audioInput";
              enabled = true;
            }
            {
              id = "nightMode";
              enabled = true;
            }
            {
              id = "darkMode";
              enabled = true;
            }
            {
              id = "doNotDisturb";
              enabled = true;
            }
            {
              id = "idleInhibitor";
              enabled = true;
            }
            {
              id = "diskUsage";
              enabled = true;
            }
            {
              id = "colorPicker";
              enabled = true;
            }
          ];
          dwlShowAllTags = true;
          lockDateFormat = "ddd d MMM yyyy";
          showWeekNumber = true;
          showWorkspaceIndex = true;
          transparency = 0;
          widgetBackgroundColor = "sc";
          widgetColorMode = "colorful";
          widgetTransparency = 0;
        };
      };

      home.packages = mkIf cfg.enable [
        cfg.package
        cfg.quickshell.package
      ];

      rb.defaults = let
        dmsIpc = args: mkDefault "dms ipc ${args}";
      in {
        apps = {
          launcher = {command = dmsIpc "launcher toggle";};
        };
        core = {
          audio = {
            # audio
            lowerVolume = {command = dmsIpc "audio decrement 5";};
            raiseVolume = {command = dmsIpc "audio increment 5";};
            micMute = {command = dmsIpc "audio micmute";};
            mute = {command = dmsIpc "audio mute";};

            # playback
            rewind = {command = dmsIpc "mpris decrement";};
            forward = {command = dmsIpc "mpris increment";};
            next = {command = dmsIpc "mpris next";};
            pause = {command = dmsIpc "mpris pause";};
            play = {command = dmsIpc "mpris playPause";};
            previous = {command = dmsIpc "mpris previous";};
            stop = {command = dmsIpc "mpris stop";};
            media = {command = dmsIpc "audio cycleoutput";};
          };
          brightness = {
            down = {command = dmsIpc "brightness decrement 5";};
            up = {command = dmsIpc "brightness increment 5";};
          };
          session = {
            lock = {command = dmsIpc "lock lock";};
            suspend = {
              command = dmsIpc "lock lock && sleep 0.3s && systemctl suspend";
              requireShell = true;
            };
            hibernate = {
              command = dmsIpc "lock lock && sleep 0.3s && systemctl hibernate";
              requireShell = true;
            };
          };
          shell = {
            toggleBar = {command = dmsIpc "bar toggle id default";};
            toggleLauncher = {command = dmsIpc "launcher toggle";};
            toggleNotifications = {command = dmsIpc "notifications toggle";};
            togglePowerMenu = {command = dmsIpc "powermenu toggle";};
            toggleProcessList = {command = dmsIpc "processlist toggle";};
            toggleSettings = {command = dmsIpc "settings toggle";};
          };
        };
      };

      systemd.user.services.dms = mkIf cfg.systemd.enable {
        Service = {
          Environment = let
            pkgsBinPath = with pkgs;
              makeBinPath [
                cfg.package
                cfg.quickshell.package
                coreutils
                gnugrep
                which
              ];
          in [
            "PATH=${pkgsBinPath}:${config.home.homeDirectory}/.nix-profile/bin:/run/current-system/sw/bin"
            "QT_QPA_PLATFORMTHEME=qt6ct"
          ];
        };
      };
    }

    (mkIf (config.sops.enable && cfg.systemd.enable) {
      rb.programs.dank-material-shell.sessionOverrides = [
        "$XDG_RUNTIME_DIR/DankMaterialShell/weather.json"
      ];

      systemd.user.services = {
        dms-weather-secret = {
          Unit = {
            Description = "Translate dms weather secret from YAML to JSON";
            After = ["sops-nix.service"];
            Requires = ["sops-nix.service"];
            Before = ["dms-pre.service"];
          };

          Service = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStart = let
              script = pkgs.writeShellScript "dms-weather-secret" ''
                set -o nounset    # Fail on use of unset variable.
                set -o errexit    # Exit on command failure.
                set -o pipefail   # Exit on failure of any command in a pipeline.
                set -o errtrace   # Trap errors in functions and subshells.

                LATITUDE=$(< "${config.sops.secrets."location/latitude".path}")
                LONGITUDE=$(< "${config.sops.secrets."location/longitude".path}")
                OUTPUT="$XDG_RUNTIME_DIR/DankMaterialShell/weather.json"

                mkdir --parents "$(dirname "$OUTPUT")"

                ${pkgs.jq}/bin/jq --null-input \
                  --arg coordinates "$LATITUDE,$LONGITUDE" \
                  '{ weatherCoordinates: $coordinates }' \
                  > "$OUTPUT"

                echo "dms-weather-secret: written → $OUTPUT"
              '';
            in "${script}";
          };

          Install.WantedBy = ["graphical-session.target"];
        };
      };
    })
  ]
