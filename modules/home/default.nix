{
  imports = [
    ./lib/module-options.nix
    ./lib/utils.nix

    ./rb/misc/defaults.nix
    ./rb/dank-material-shell.nix
    ./rb/screenshot.nix

    ./programs/git.nix
    ./programs/gopass.nix
    ./programs/yazi.nix

    ./services/gocryptfs.nix
    ./services/kanata.nix
    ./services/map-ssh-identities.nix
  ];
}
