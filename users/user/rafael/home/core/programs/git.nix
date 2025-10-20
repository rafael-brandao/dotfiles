{
  config,
  lib,
  ...
}:
with lib;
  mkMerge [
    {
      programs = {
        git = {
          settings = {
            alias = {
              a = "add --patch";
              b = "branch";
              ba = "branch --all";
              c = "commit --message";
              ca = "commit --all --message";
              co = "checkout";
              coall = "checkout -- .";
              d = "diff";
              # dv = "difftool -t vimdiff -y";
              gl = "config --global --list";
              last = "log -1 HEAD --stat";
              ll = "log --oneline";
              lo = "log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit";
              p = "push origin HEAD";
              pu = "pull origin";
              r = "remote";
              re = "reset";
              rv = "remote --verbose";
              se = "!git rev-list --all | xargs git grep --fixed-strings"; # search for specific strings in your commits
              st = "status";
              sts = "status --branch --short";
            };
            gpg.format = mkDefault "ssh";
          };
          providers.rewriteProtocol = mkDefault "ssh";
        };
        difftastic = {
          enable = mkDefault true;
          options = {
            background = mkDefault "dark";
          };
          git = {
            enable = mkDefault true;
            diffToolMode = mkDefault true;
          };
        };
      };
    }
    (mkIf config.sops.enable {
      programs.git.includes = mkBefore [
        {
          inherit (config.sops.secrets."git/personal.gitconfig") path;
        }
      ];
      sops.secrets = {
        "git/personal.gitconfig" = {
          path = "${config.xdg.configHome}/git/personal.gitconfig";
        };
      };
    })
  ]
