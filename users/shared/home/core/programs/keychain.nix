{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.keychain;
in {
  programs.keychain = {
    enable = mkIf (length cfg.keys > 0) (mkDefault true);
    keys = [];
    enableBashIntegration = mkDefault config.programs.bash.enable;
    enableFishIntegration = mkDefault config.programs.fish.enable;
    extraFlags = mkDefault [ "--quiet" "--immediate" ];
  };
}
