{
  imports = [
    ./lib/module-options.nix
    ./lib/utils.nix

    ./programs/git.nix
    ./programs/gopass.nix
    ./programs/yazi.nix

    ./services/gocryptfs.nix
    ./services/map-ssh-identities.nix
  ];
}
