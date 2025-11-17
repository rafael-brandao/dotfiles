# {pkgs, ...}: {
{
  boot = {
    initrd = {
      network.enable = true;
      clevis = {
        enable = true;
        useTang = true;
        devices = {
          "cryptroot".secretFile = "/etc/clevis/cryptroot.jwe";
          "cryptswap".secretFile = "/etc/clevis/cryptswap.jwe";
        };
      };
    };
    kernelParams = [
      "i915.enable_guc=3" # GuC/HuC firmware
    ];
  };
  security.sudo = {
    wheelNeedsPassword = false;
  };
  services = {
    avahi = {
      publish.enable = true;
      publish.userServices = true;
    };
    getty.autologinUser = "rafael";
    spice-autorandr.enable = true;
    spice-vdagentd.enable = true;
    spice-webdavd.enable = true;
    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };
  };
}
