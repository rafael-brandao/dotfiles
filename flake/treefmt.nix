{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem = _: {
    treefmt.config = {
      flakeCheck = false; # git-hooks.nix checks this
      programs = {
        alejandra.enable = true;
        deadnix.enable = true;
        jsonfmt.enable = true;
        statix.enable = true;
        stylua.enable = true;
        toml-sort.enable = true;
        yamlfmt.enable = true;
      };
      settings = {
        formatter = {
          # Lua
          stylua.includes = [".luacheckrc"];
          # Nix
          deadnix.priority = 1;
          statix.priority = 2;
          alejandra.priority = 3;
          # Yaml
          yamlfmt.includes = [".yamlfmt" ".yamllint"];
        };
        global.excludes = [
          "LICENSE"
          "justfile"
          # unsupported extensions
          "*.{editorconfig,env,envrc,gif,gitignore,jpg,lock,mod,mts,pages,pem,png,ps1,sum,svg,tape,toml}"
        ];
      };
    };
  };
}
