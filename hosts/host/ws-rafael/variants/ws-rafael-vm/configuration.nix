_: {
  boot.initrd = {
    clevis = {
      enable = true;
      useTang = true;
      devices = {
        "cryptroot".secretFile = "/etc/clevis/cryptroot.jwe";
        "cryptswap".secretFile = "/etc/clevis/cryptswap.jwe";
      };
    };
    network = {
      enable = true;
      # udhcpc.enable = true;
    };
  };
  environment.etc = {
    "clevis/cryptroot.jwe" = {
      source = ./secrets/cryptroot.jwe;
      # optional but recommended: restrict permissions and ownership
      mode = "0400";
      user = "root";
      group = "root";
    };
    "clevis/cryptswap.jwe" = {
      source = ./secrets/cryptswap.jwe;
      mode = "0400";
      user = "root";
      group = "root";
    };
  };
  security.sudo = {
    wheelNeedsPassword = false;
  };
  services = {
    spice-autorandr.enable = true;
    spice-vdagentd.enable = true;
    spice-webdavd.enable = true;
  };
}
