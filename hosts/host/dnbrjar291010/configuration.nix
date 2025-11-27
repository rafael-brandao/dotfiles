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

  # ───── Force RTX 3050 instead of Intel iGPU ─────
  environment.variables = {
    # These three lines are the magic on Optimus laptops
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # MESA_LOADER_DRIVER_OVERRIDE = "zink"; # OpenGL → Vulkan → D3D12 → RTX 3050
    # MESA_D3D12_DEFAULT_ADAPTER_NAME = "NVIDIA GeForce RTX 3050 Laptop GPU";

    # Bonus for video decoding in Firefox/mpv/etc.
    # LIBVA_DRIVER_NAME = "nvidia";
  };

  hardware = {
    cpu.intel.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;

    graphics = {
      extraPackages = with pkgs; [
        # cudaPackages.cudatoolkit
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
