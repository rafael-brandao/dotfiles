{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
  mkIf config.programs.tmux.enable
  {
    programs.tmux = mkMerge [
      {
        baseIndex = 1;
        clock24 = true;
        customPaneNavigationAndResize = true; # hjkl/HJKL pane nav+resize, only wires up under keyMode = "vi"
        escapeTime = 10; # module default already, set explicitly for clarity
        focusEvents = true;
        historyLimit = 50000;
        keyMode = "vi";
        mouse = true;
        shell = mkIf config.programs.fish.enable (mkDefault (getExe config.programs.fish.package));
        terminal = "xterm-256color";

        extraConfig = ''
          set -g status-position top
        '';

        plugins = with pkgs.tmuxPlugins; [
          {
            plugin = resurrect;
            extraConfig = ''
              set -g @resurrect-strategy-nvim 'session'
              set -g @resurrect-capture-pane-contents 'on'
            '';
          }
          {
            plugin = continuum;
            extraConfig = ''
              set -g @continuum-restore 'on'
              set -g @continuum-save-interval '15'
            '';
          }
        ];
      }
      (mkIf config.stylix.targets.tmux.enable {
        extraConfig = mkBefore ''
          set-environment -g TINTED_TMUX_OPTION_ACTIVE 1
          set-environment -g TINTED_TMUX_OPTION_STATUSBAR 1
        '';
      })
    ];
  }
