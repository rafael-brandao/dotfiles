{
  config,
  lib,
  ...
}:
with lib;
  mkIf config.programs.zellij.enable (
    mkMerge [
      {
        programs.zellij = {
          # Disabled to silence a build warning: <paste warning text or reason here>.
          # This only exported ZELLIJ_AUTO_ATTACH (reattach to an existing session
          # instead of spawning a duplicate), so new shells now start a fresh session.
          # attachExistingSession = mkDefault true;

          exitShellOnExit = mkDefault false; # ZELLIJ_AUTO_EXIT: drop back to fish, don't kill the terminal

          settings = {
            default_layout = "default";
            # theme = "default"; # swap for whatever DMS-coordinated theme you land on
            # theme = mkDefault "catppuccin-mocha";
            # session_serialization = true;
            pane_frames = true;
            mouse_mode = true;
          };

          extraConfig =
            # kdl
            ''
              keybinds {
                normal {
                  bind "Ctrl Space" { GoToNextTab; }
                  bind "Ctrl Shift Space" { GoToPreviousTab; }
                }
                locked {
                  bind "Ctrl Space" { GoToNextTab; }
                  bind "Ctrl Shift Space" { GoToPreviousTab; }
                }
              }
            '';
        };
      }
      (mkIf config.programs.fish.enable {
        programs.zellij = {
          # enableFishIntegration = mkDefault true;
          settings = {
            default_shell = mkDefault "fish";
          };
        };
      })
      (mkIf config.stylix.targets.zellij.enable {
        programs.zellij.settings = {
          explicit_theme_hue = mkIf (elem config.stylix.polarity ["light" "dark"]) (mkDefault config.stylix.polarity);
        };
      })
    ]
  )
