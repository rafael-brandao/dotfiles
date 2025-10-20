{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.wayland.windowManager.mango;
in {
  wayland.windowManager.mango = mkIf cfg.enable {
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
}
