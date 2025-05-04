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
}
