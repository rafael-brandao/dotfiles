{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.wayland.windowManager.mango;
in
  mkIf cfg.enable {
    wayland.windowManager.mango = {
      autostart_sh =
        # bash
        ''
          echo 'Starting MangoWC'
        '';
      settings = {
        bind = [
          "SUPER,r,reload_config"
          "SUPER,Return,spawn,ghostty"
        ];
      };
    };

    home.file.".profile" = {
      text =
        #bash
        ''
          # Start mango on the first virtual terminal without a display running
          if [ -z "''${WAYLAND_DISPLAY}" ] && [ -z "''${DISPLAY}" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
            exec mango
          fi
        '';
    };
  }
