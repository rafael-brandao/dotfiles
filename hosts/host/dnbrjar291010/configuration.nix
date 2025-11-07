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

  # firewall = {
  #   enable = true;
  #   allowedTCPPorts = [22 7654];
  # };

  hardware = {
    cpu.intel.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;
    graphics = {
      extraPackages = with pkgs; [
        mesa
      ];
    };
  };

  nixpkgs.config.packageOverrides = pkgs: {
    intel-vaapi-driver = pkgs.intel-vaapi-driver.override {enableHybridCodec = true;};
  };

  programs = {
    dconf.enable = true;
  };

  services = {
    dbus = {
      enable = true;
      # packages = with pkgs; [
      #   tiramisu
      # ];
    };
    tang = {
      enable = true;
      listenStream = [
        "7654"
      ];
      # Restrict to VM subnet (QEMU user-mode: 10.0.2.0/24)
      ipAddressAllow = [
        "127.0.0.0/8"
        "10.0.2.0/24"
      ];
    };
  };
}
