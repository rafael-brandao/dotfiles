{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  hardware = {
    cpu.intel.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;
    graphics = {
      extraPackages = with pkgs; [
        mesa
      ];
    };
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
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
  };

  wsl.defaultUser = "rafael";
}
