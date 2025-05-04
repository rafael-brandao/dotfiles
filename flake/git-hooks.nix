{inputs, ...}: {
  imports = [inputs.git-hooks.flakeModule];

  perSystem = {pkgs, ...}: {
    pre-commit = {
      check.enable = true;
      settings.hooks = {
        check-symlinks.enable = true;
        convco.enable = true;
        deadnix.enable = true;
        editorconfig-checker.enable = true;
        flake-checker.enable = true;
        # gptcommit.enable = true; # TODO: research, study and then configure gptcommit
        lua-ls.enable = true;
        markdownlint.enable = true;
        nil = {
          enable = true;
          package = pkgs.nil-git;
        };
        statix.enable = true;
        treefmt.enable = true;
        trim-trailing-whitespace.enable = true;
        yamllint.enable = true;
      };
    };
  };
}
