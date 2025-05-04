{
  lib,
  modulesPath,
  ...
}:
with lib; {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    # (modulesPath + "/installer/cd-dvd/installation-cd-minimal-new-kernel.nix")
  ];

  networking = {
    enableIPv6 = mkOverride 500 false;
    useDHCP = mkOverride 500 true;
  };

  # INFO: Needed for https://github.com/NixOS/nixpkgs/issues/58959
  nixpkgs.config.allowBroken = mkOverride 500 true;

  # INFO: These settings are exclusively to allow root login over ssh on a live iso
  services = {
    kmscon.autologinUser = mkOverride 500 "nixos";
    openssh = {
      enable = mkOverride 500 true;
      settings = {
        # PasswordAuthentication = mkOverride 500 true;
        PermitRootLogin = mkOverride 500 "yes";
      };
    };
  };

  users = {
    # allowNoPasswordLogin = mkOverride 500 true;
    users.root = {
      # hashedPassword = mkOverride 500 "!"; # < disable password login for root
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG3GJXN37jo2h3fRmpOBwk7oiLhloY9qCmyCwG5ml4FC"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAczeNl3H+oLiaZT0jSGS+p4O8dKS14ahBY9qifB9Fqf"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOXX5fjPp6lZYLGAHj6+UmMhE+5bmvAWoOJRqN9Fe9O7"
      ];
    };
  };
}
