_: {
  imports = [
    ./lib
    ./devshells.nix
    # ./git-hooks.nix # TODO: disabled beacause JuJutsu doesn't allow git hooks
    ./just-flake.nix
    ./local.nix
    ./overlays.nix
    ./packages.nix
    ./treefmt.nix
  ];
}
