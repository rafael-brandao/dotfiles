{
  config,
  lib,
  ...
}: let
  cfg = config.programs.mergiraf;
in
  with lib;
    mkIf cfg.enable {
      programs.mergiraf = {
        enableGitIntegration = mkDefault config.programs.git.enable;
        enableJujutsuIntegration = mkDefault config.programs.jujutsu.enable;
      };
    }
