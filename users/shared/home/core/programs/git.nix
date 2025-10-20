{
  config,
  hostcfg,
  lib,
  pkgs,
  ...
}:
with lib;
  mkIf config.programs.git.enable {
    programs = {
      git = {
        package = mkDefault pkgs.gitAndTools.gitFull;
        settings = {
          color = {
            ui = true;
          };
          core.autocrlf = mkDefault "input";
          credential.helper = mkDefault "store";
          fetch.prune = mkDefault true;
          grep.lineNumber = mkDefault true;
          help.autocorrect = mkDefault 1;
          init.defaultBranch = mkDefault "master";
          pull.rebase = mkDefault true;
        };
      };
      lazygit = {
        enable = mkDefault true;
      };
    };

    home.packages = with pkgs;
      [
        # git-crypt # transparent file encryption in git
        git-lfs # git extension for versioning large files
        gnupg #   modern (2.1) release of the GNU Privacy Guard, a GPL OpenPGP implementation
        hub #     command-line wrapper for git that makes you better at GitHub
        lab #     lab wraps Git or Hub, making it simple to clone, fork, and interact with repositories on GitLab
        tig #     git terminal ui frontend
      ]
      ++ (
        optionals (hostcfg.info.hasAnyTagIn ["desktop" "wsl"]) [
          smartgithg # GUI for Git, Mercurial, Subversion
        ]
      );
  }
