{
  config,
  lib,
  ...
}:
with lib;
  mkIf config.sops.enable {
    sops.secrets = {
      "dtp/git/conditions.gitconfig" = {
        key = "git/conditions";
        sopsFile = ./secrets.yaml;
      };
      "dtp/git/dtp.gitconfig" = {
        key = "git/config";
        sopsFile = ./secrets.yaml;
      };
      "dtp/gocryptfs/mounts/01/gocryptfs.conf" = {
        key = "gocryptfs/mounts/_01/config";
        mode = "0400";
        sopsFile = ./secrets.yaml;
      };
      "dtp/gocryptfs/mounts/01/passfile" = {
        key = "gocryptfs/mounts/_01/password";
        mode = "0400";
        sopsFile = ./secrets.yaml;
      };
      "dtp/gocryptfs/mounts/01/masterkey" = {
        key = "gocryptfs/mounts/_01/masterKey";
        mode = "0400";
        sopsFile = ./secrets.yaml;
      };
      "dtp/rclone/01/rclone.conf" = {
        key = "rclone/_01/rclone.conf";
        mode = "0600";
        sopsFile = ./secrets.yaml;
      };
      "dtp/ssh/identities/01/identity" = {
        key = "ssh/identities/_01/identity";
        mode = "0400";
        sopsFile = ./secrets.yaml;
      };
      "dtp/ssh/identities/01/id_ed25519" = {
        key = "ssh/identities/_01/id_ed25519";
        mode = "0400";
        sopsFile = ./secrets.yaml;
      };
      "dtp/ssh/identities/01/id_ed25519.pub" = {
        key = "ssh/identities/_01/id_ed25519.pub";
        mode = "0444";
        sopsFile = ./secrets.yaml;
      };
      "dtp/syncrclone/01/config.py" = {
        key = "syncrclone/_01/config.py";
        mode = "0400";
        sopsFile = ./secrets.yaml;
      };
    };
  }
