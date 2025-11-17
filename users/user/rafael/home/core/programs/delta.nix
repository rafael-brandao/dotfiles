{
  config,
  lib,
  ...
}: let
  cfg = config.programs.delta;
in
  with lib;
    mkIf cfg.enable {
      programs.delta = {
        enableGitIntegration = mkOverride 2000 config.programs.git.enable;
        enableJujutsuIntegration = mkOverride 2000 config.programs.jujutsu.enable;
        options = {
          features = mkDefault "side-by-side line-numbers decorations";
          syntax-theme = mkDefault "Dracula";
          plus-style = mkDefault ''syntax "#003800"'';
          minus-style = mkDefault ''syntax "#3f0001"'';
          whitespace-error-style = mkDefault "22 reverse";
          decorations = {
            commit-decoration-style = mkDefault "bold yellow box ul";
            file-style = mkDefault "bold yellow ul";
            file-decoration-style = mkDefault "none";
            hunk-header-decoration-style = mkDefault "cyan box ul";
          };
          line-numbers = {
            line-numbers-left-style = mkDefault "cyan";
            line-numbers-right-style = mkDefault "cyan";
            line-numbers-minus-style = mkDefault "124";
            line-numbers-plus-style = mkDefault "28";
          };
        };
      };
    }
