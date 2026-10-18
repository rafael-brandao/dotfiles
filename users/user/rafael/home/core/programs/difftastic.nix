{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.difftastic;
  difftCommand = "${getExe cfg.package} ${cli.toCommandLineShellGNU {} cfg.options}";
  inherit (config) stylix;
in
  mkIf cfg.enable {
    programs.difftastic = mkMerge [
      {
        jujutsu.enable = mkDefault config.programs.jujutsu.enable;
        options = {
          background = mkOverride 1010 "dark";
          color = mkDefault "always";
          sort-paths = mkDefault true;
        };
      }
      (mkIf stylix.enable {
        options = {
          background =
            mkIf (elem stylix.polarity ["dark" "light"]) (mkDefault stylix.polarity);
        };
      })
    ];

    programs.git = mkIf config.programs.git.enable {
      settings = {
        difftool = {
          difftastic.cmd = mkDefault "${difftCommand} $LOCAL $REMOTE";
        };
        alias = {
          # git diff pipes through the pager, so difft needs --color=always.
          # show and log only use an external diff when given --ext-diff.
          dft = mkDefault "-c 'diff.external=${difftCommand}' diff";
          dfts = mkDefault "-c 'diff.external=${difftCommand}' show --ext-diff";
          dftl = mkDefault "-c 'diff.external=${difftCommand}' log --patch --ext-diff";
        };
      };
    };
  }
