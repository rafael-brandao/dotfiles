{lib, ...}:
with lib; {
  services = {
    openssh = {
      enable = mkOverride 500 true;
      settings = {
        PermitRootLogin = mkOverride 500 "yes";
      };
    };
  };

  users = {
    users.root = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG3GJXN37jo2h3fRmpOBwk7oiLhloY9qCmyCwG5ml4FC"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPCxewEtgon+04yiXzNTAhI2uWFiM3Sy9tRQdfsQtAnn"
      ];
    };
  };
}
