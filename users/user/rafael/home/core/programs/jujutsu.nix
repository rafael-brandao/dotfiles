{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.jujutsu;
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
            editor = mkDefault "nvim";
            pager = with config.programs; mkIf (!delta.enableJujutsuIntegration && bat.enable) (mkDefault "bat -p");
          };
          user = {
            name = mkDefault "Rafael Brandão";
            email = mkDefault "rafa.bra.dev@pm.me";
          };
        };
      };
      jjui = {
        enable = mkDefault cfg.enable;
      };
    };
  }
