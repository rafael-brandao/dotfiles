{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.delta;
  gitCfg = config.programs.git;
  delta = getExe cfg.finalPackage;
in
  mkIf cfg.enable {
    programs.delta = {
      enableGitIntegration = mkDefault gitCfg.enable;
      enableJujutsuIntegration = mkDefault config.programs.jujutsu.enable;
      options = {
        hyperlinks = mkDefault true;
        line-numbers = mkDefault true;
        navigate = mkDefault true;
      };
    };

    programs.git = mkIf (gitCfg.enable && cfg.enableGitIntegration) {
      settings.alias = {
        dl = "-c core.pager=${delta} diff";
        dls = "-c core.pager=${delta} show";
        dll = "-c core.pager=${delta} log --patch";
        dlsbs = "-c 'core.pager=${delta} --side-by-side' diff";
      };
    };
  }
