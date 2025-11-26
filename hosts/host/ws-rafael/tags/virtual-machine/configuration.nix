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
  };
  security.sudo = {
    wheelNeedsPassword = false;
  };
}
