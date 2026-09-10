{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  wsl = {
    defaultUser = "rafael";
  };

  hardware = {
    cpu.intel.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;

    graphics = {
      extraPackages = with pkgs; [
        libvdpau-va-gl # VDPAU → VA-API bridge (helps some apps)
        mesa
        nvidia-vaapi-driver # NVDEC/NVENC video acceleration
      ];
    };
  };

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override {enableHybridCodec = true;};
  };

  services = {
    tang = {
      enable = true;
      listenStream = [
        "0.0.0.0:7654"
      ];
      # Restrict to VM subnet (QEMU user-mode: 10.0.2.0/24)
      ipAddressAllow = [
        "127.0.0.0/8"
        "10.0.2.0/24"
      ];
    };
  };
}
