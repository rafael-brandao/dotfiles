{
  boot = {
    initrd = {
      network = {
        enable = true;
        flushBeforeStage2 = true;
      };

      clevis = {
        enable = true;
        useTang = true;
        devices = {
          "cryptroot".secretFile = "/etc/clevis/cryptroot.jwe";
          "cryptswap".secretFile = "/etc/clevis/cryptswap.jwe";
        };
      };
      systemd = {
        enable = true;
        emergencyAccess = true;
        network = {
          enable = true;
          networks."10-eth" = {
            matchConfig.Type = "ether";
            networkConfig.DHCP = "ipv4";
          };
        };
      };
    };
  };
  security.sudo = {
    wheelNeedsPassword = false;
  };
}
