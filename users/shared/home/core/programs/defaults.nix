{
  config,
  hostcfg,
  lib,
  pkgs,
  ...
}:
with lib; let
  hostIsDesktop = hostcfg.info.hasAnyTagIn ["desktop" "workstation"];
in {
  config = {
    assertions = [
      (let
        cfg = config.rb.defaults;

        # terminalLauncher is only defined on desktop hosts
        hasTerminalLauncher =
          !hostIsDesktop
          || (cfg.apps ? terminalLauncher
            && cfg.apps.terminalLauncher.enable);

        filterFn = filterAttrs (_name: app: app.isTui && !hasTerminalLauncher);
        invalidStateApps = pipe cfg.apps [filterFn attrNames];
      in {
        assertion = length invalidStateApps == 0;
        message = ''
          rb.defaults: TUI apps require terminalLauncher on desktop hosts.

          Affected apps: ${mkString {sep = ", ";} invalidStateApps}

          Please configure rb.defaults.apps.terminalLauncher.
        '';
      })
    ];

    rb.defaults = {
      settings = {
        apps = {
          home = {
            autoEnableProgram = mkDefault true;
            installPackage = mkDefault true;
          };
          xdgMime.autoRegisterPackage = mkDefault true;
        };
      };

      apps = mkMerge [
        {
          calculator = {
            name = mkDefault "qalc";
            envVars = ["CALC"];
            isTui = mkDefault true;
          };

          editor = {
            name = mkDefault "micro";
            desktopFileId = mkDefault "micro.desktop";
            envVars = ["EDITOR"];
            isTui = mkDefault true;
          };

          fileManager = {
            name = mkDefault "yazi";
            desktopFileId = mkDefault "yazi.desktop";
            envVars = ["FILE_MANAGER"];
            isTui = mkDefault true;
          };

          systemMonitor = {
            name = mkDefault "btop";
            desktopFileId = mkDefault "btop.desktop";
            envVars = ["SYSTEM_MONITOR"];
            isTui = mkDefault true;
          };
        }

        (mkIf hostIsDesktop {
          guiCalculator = {
            name = mkDefault "qalculate-gtk";
            desktopFileId = mkDefault "qalculate-gtk.desktop";
            envVars = ["CALCULATOR" "GUI_CALCULATOR"];
            keyBindings = ["XF86Calculator"];
          };

          guiEditor = {
            name = mkDefault "gedit";
            desktopFileId = mkDefault "org.gnome.gedit.desktop";
            envVars = ["GUI_EDITOR" "VISUAL"];
          };

          guiFileManager = {
            name = mkDefault "nautilus";
            desktopFileId = mkDefault "org.gnome.Nautilus.desktop";
            envVars = ["GUI_FILE_MANAGER"];
            keyBindings = ["XF86Explorer"];
          };

          guiSystemMonitor = {
            name = mkDefault "mission-center";
            command = mkDefault "missioncenter";
            desktopFileId = mkDefault "io.missioncenter.MissionCenter.desktop";
            envVars = ["GUI_SYSTEM_MONITOR"];
            keyBindings = ["XF86TaskPane"];
          };

          launcher = {
            envVars = ["LAUNCHER"];
            keyBindings = ["XF86LaunchA"];
          };

          screenshotTool = {
            command = mkIf config.rb.screenshot.enable (mkDefault config.rb.screenshot.executableName);
            envVars = ["SCREENSHOT_TOOL"];
            keyBindings = ["Print"];
          };

          terminal = {
            name = mkDefault "ghostty";
            desktopFileId = mkDefault "com.mitchellh.ghostty.desktop";
            envVars = ["TERMINAL"];
            keyBindings = ["XF86DOS"];
          };

          terminalLauncher = {
            name = mkDefault "ghostty";
            desktopFileId = mkDefault "com.mitchellh.ghostty.desktop";
            args = ["-e"];
          };

          webBrowser = {
            name = mkDefault "zen-twilight";
            package = pkgs.zen-browser-twilight;
            desktopFileId = mkDefault "zen-twilight.desktop";
            envVars = ["WEB_BROWSER"];
            keyBindings = ["XF86WWW"];
          };
        })
      ];

      core = {
        audio = {
          # audio controls
          lowerVolume = {keyBindings = ["XF86AudioLowerVolume"];};
          raiseVolume = {keyBindings = ["XF86AudioRaiseVolume"];};
          micMute = {keyBindings = ["XF86AudioMicMute"];};
          mute = {keyBindings = ["XF86AudioMute"];};

          # playback controls
          rewind = {keyBindings = ["XF86AudioRewind"];};
          forward = {keyBindings = ["XF86AudioForward"];};
          next = {keyBindings = ["XF86AudioNext"];};
          pause = {keyBindings = ["XF86AudioPause"];};
          play = {keyBindings = ["XF86AudioPlay"];};
          previous = {keyBindings = ["XF86AudioPrev"];};
          stop = {keyBindings = ["XF86AudioStop"];};
          media = {keyBindings = ["XF86AudioMedia"];};
        };
        brightness = {
          cycle = {keyBindings = ["XF86MonBrightnessCycle"];};
          down = {keyBindings = ["XF86MonBrightnessDown"];};
          up = {keyBindings = ["XF86MonBrightnessUp"];};
        };
        session = {
          lock = {keyBindings = ["XF86ScreenSaver"];};
          logOff = {};
          powerOff = {keyBindings = ["XF86PowerOff"];};
          reboot = {};
          suspend = {keyBindings = ["XF86Suspend" "XF86Sleep"];};
          hibernate = {};
        };
        shell = {
          toggleBar = {};
          toggleLauncher = {};
          toggleNotifications = {};
          togglePowerMenu = {};
          toggleProcessList = {};
          toggleSettings = {};
        };
      };
    };
  };
}
