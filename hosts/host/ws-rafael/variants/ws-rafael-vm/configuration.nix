_: let
  inherit (builtins) readFile toFile;
in {
  boot.initrd = {
    clevis = {
      enable = true;
      useTang = true;
      devices = {
        "cryptroot".secretFile = toFile "cryptroot.jwe" (readFile ./secrets/cryptroot.jwe);
        "cryptswap".secretFile = toFile "cryptswap.jwe" (readFile ./secrets/cryptswap.jwe);
      };
    };
    network = {
      enable = true;
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
