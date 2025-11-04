{
  lib,
  modulesPath,
  ...
}:
with lib; {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # -------------------------------------------------
  # Enable 9p kernel modules
  # -------------------------------------------------
  boot.kernelModules = [
    "9p"
    "9pnet_virtio"
  ];

  services.qemuGuest.enable = mkDefault true;
}
