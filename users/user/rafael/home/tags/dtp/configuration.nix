{
  imports = [
    ./secrets
    ./misc/ssh.nix
    ./programs/git.nix
    ./programs/gopass.nix
    # ./programs/syncrclone.nix
    ./services/gocryptfs.nix
  ];
}
