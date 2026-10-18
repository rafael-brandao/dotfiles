{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.jujutsu;
  batCfg = config.programs.bat;
  batCommand = "${getExe batCfg.package} ${cli.toCommandLineShellGNU {} {plain = true;}}";
in
  mkIf cfg.enable {
    programs = {
      jujutsu = {
        settings = {
          remotes = {
            origin.auto-track-bookmarks = mkDefault "glob:*";
          };
          ui = {
            color = mkDefault "always";
            default-command = mkDefault "log";
            diff-formatter = mkOverride 90 ":git";
            editor = mkDefault "nvim";
            pager = mkIf batCfg.enable (mkOverride 1010 batCommand);
          };
        };
      };
      jjui = {
        enable = mkDefault cfg.enable;
      };
    };
  }
