{inputs, ...}: {
  imports = with inputs; [
    flake-root.flakeModule
  ];
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      name = "dotfiles-developer-shell";
      inputsFrom = with config; [
        flake-root.devShell
        just-flake.outputs.devShell
        # pre-commit.devShell
        treefmt.build.devShell
        packages.neovim-developer
      ];
      packages =
        (with pkgs; [
          age
          git
          jujutsu
          nixos-anywhere
          nixVersions.latest
          sops
          ssh-to-age
          tokei
        ])
        ++ (with config.packages; [
          neovim-developer
        ]);
    };
  };
}
