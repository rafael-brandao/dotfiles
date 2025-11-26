{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.dankMaterialShell;
in
  mkIf cfg.enable {
    programs.dankMaterialShell = {
      quickshell.package = mkDefault pkgs.quickshell;
      systemd.enable = mkDefault true;

      # Core features
      enableSystemMonitoring = mkDefault true; # System monitoring widgets (dgop)
      enableClipboard = mkDefault true; # Clipboard history manager
      enableVPN = mkDefault true; # VPN management widget
      enableBrightnessControl = mkDefault true; # Backlight/brightness controls
      enableColorPicker = mkDefault true; # Color picker tool
      enableDynamicTheming = mkDefault true; # Wallpaper-based theming (matugen)
      enableAudioWavelength = mkDefault true; # Audio visualizer (cava)
      enableCalendarEvents = mkDefault true; # Calendar integration (khal)
      enableSystemSound = mkDefault true; # System sound effects
    };

    systemd.user.services.dms = mkIf cfg.systemd.enable {
      Service.Environment = [
        "PATH=${config.home.homeDirectory}/.nix-profile/bin:/run/current-system/sw/bin"
      ];
    };
  }
