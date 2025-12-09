{
  inputs,
  lib,
  ...
}: let
  overlays = {
    additions = with lib;
      final: prev: let
        inherit (final.stdenv.hostPlatform) system;
      in {
        neovim-nightly = inputs.neovim-nightly.packages.${system}.neovim;

        nil-git = inputs.nil.packages.${system}.nil;

        stable = mkPkgs {
          inherit system;
          nixpkgs = inputs.nixpkgs-stable;
        };

        vimPlugins = with final.vimUtils;
          prev.vimPlugins
          // {
            blink-cmp-nightly = inputs.blink-cmp.packages.${system}.blink-cmp;

            snacks-nvim-git = buildVimPlugin {
              name = "snacks.nvim";
              src = inputs.snacks-nvim;
              doCheck = false;
            };
            todo-comments-nvim-git = buildVimPlugin {
              name = "todo-comments.nvim";
              src = inputs.todo-comments-nvim;
              doCheck = false;
            };
            trouble-nvim-git = buildVimPlugin {
              name = "trouble.nvim";
              src = inputs.trouble-nvim;
              doCheck = false;
            };
          };

        zen-browser = mkIf (elem system ["aarch64-linux" "x86_64-linux"]) inputs.zen-browser.packages.${system}.default;
        zen-browser-twilight = mkIf (elem system ["aarch64-linux" "x86_64-linux"]) inputs.zen-browser.packages.${system}.twilight;

        local = inputs.self.packages.${system};
      };

    # Overlays from inputs
    nixgl = inputs.nixgl.overlay;
  };

  mkPkgs = {
    nixpkgs,
    overlays ? [],
    system,
  }:
    import nixpkgs {
      inherit overlays system;
      config.allowUnfree = true;
    };

  pkgsFor = system:
    mkPkgs {
      inherit system;
      inherit (inputs) nixpkgs;
      overlays = lib.attrValues overlays;
    };
in {
  flake = {
    inherit pkgsFor overlays;
  };
  perSystem = {system, ...}: {
    _module.args = {
      pkgs = pkgsFor system;
    };
  };
}
