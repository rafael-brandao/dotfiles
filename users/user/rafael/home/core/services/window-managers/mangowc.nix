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
      autostart_sh = ''
        echo 'Starting MangoWC'
      '';
      settings = ''
        # Reload config
        bind=SUPER,r,reload_config

        # Terminal
        bind=SUPER,Return,spawn,ghostty
      '';
    };

    home.file.".profile" = {
      text = ''
        if [ -z "''${DISPLAY}" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
          exec mango
        fi
      '';
    };
  }
