{
  lib,
  modulesPath,
  ...
}:
with lib; {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  services.qemuGuest.enable = mkDefault true;
}
