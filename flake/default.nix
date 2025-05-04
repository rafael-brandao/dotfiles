_: {
  imports = [
    ./lib
    ./devshells.nix
    # ./git-hooks.nix # TODO: disabled beacause JuJutsu doesn't allow git hooks
    ./just-flake.nix
    ./overlays.nix
    ./packages.nix
    ./treefmt.nix
  ];
}
