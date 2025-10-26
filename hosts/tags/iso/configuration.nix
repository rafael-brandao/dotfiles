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

  nixpkgs = {
    config.allowBroken = mkOverride 500 true;
  };

  services = {
    kmscon.autologinUser = mkOverride 500 "nixos";
  };

  # Remove the installer variant ID so nixos-anywhere will use kexec
  # environment.etc."os-release".text = lib.mkForce ''
  #   NAME=NixOS
  #   ID=nixos
  #   PRETTY_NAME="NixOS"
  # '';
}
