{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.dank-material-shell;
in {
  programs.dank-material-shell = {
    quickshell.package = mkDefault pkgs.quickshell;
    systemd.enable = mkDefault true;

    # Core features
    enableSystemMonitoring = mkDefault true; # System monitoring widgets (dgop)
    enableVPN = mkDefault true; # VPN management widget
    enableDynamicTheming = mkDefault true; # Wallpaper-based theming (matugen)
    enableAudioWavelength = mkDefault true; # Audio visualizer (cava)
    enableCalendarEvents = mkDefault true; # Calendar integration (khal)
  };

  home.packages = [
    cfg.quickshell.package
  ];

  systemd.user.services.dms = mkIf cfg.systemd.enable {
    Service.Environment = let
      pkgsBinPath = makeBinPath [
        cfg.quickshell.package
      ];
    in [
      # "PATH=${pkgsBinPath}:${config.home.homeDirectory}/.nix-profile/bin:/run/current-system/sw/bin"
      "PATH=${pkgsBinPath}"
    ];
  };
}
