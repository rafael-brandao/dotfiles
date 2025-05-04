{
  config,
  lib,
  ...
}:
with lib;
  mkIf config.sops.enable {
    programs.git.includes = [
      {
        inherit (config.sops.secrets."dtp/git/conditions.gitconfig") path;
      }
    ];

    sops.secrets = {
      "dtp/git/conditions.gitconfig" = {
        path = "${config.xdg.configHome}/git/dtp/conditions.gitconfig";
      };
      "dtp/git/dtp.gitconfig" = {
        path = "${config.xdg.configHome}/git/dtp/dtp.gitconfig";
      };
    };
  }
