{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = {
    boot = {
      loader = {
        efi.canTouchEfiVariables = true;
        systemd-boot = {
          enable = true;
        };
        supportsInitrdSecrets = true;
      };
      supportedFilesystems = ["btrfs" "ntfs"];
    };

    hardware = {
      bluetooth.enable = true;
      cpu.intel.updateMicrocode = config.hardware.enableRedistributableFirmware;

      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          intel-media-driver # LIBVA_DRIVER_NAME=iHD
          vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
          vaapiVdpau
          libvdpau-va-gl
        ];
        extraPackages32 = with pkgs.pkgsi686Linux; [
          vaapiIntel
        ];
      };
    };

    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override {enableHybridCodec = true;};
    };

    programs.mango.enable = true;

    users = {
      users.root = {
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG3GJXN37jo2h3fRmpOBwk7oiLhloY9qCmyCwG5ml4FC"
        ];
      };
    };
  };
}
