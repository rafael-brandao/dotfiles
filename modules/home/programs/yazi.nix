{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.yazi;
in {
  config.programs.yazi = mkIf cfg.enable {
    enableBashIntegration = mkDefault config.programs.bash.enable;
    enableFishIntegration = mkDefault config.programs.fish.enable;
    enableNushellIntegration = mkDefault config.programs.nushell.enable;
    enableZshIntegration = mkDefault config.programs.zsh.enable;
  };
}
