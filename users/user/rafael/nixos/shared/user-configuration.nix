usercfg: {
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  description = mkDefault (
    if (usercfg.description == "")
    then "Rafael"
    else usercfg.description
  );
  shell = mkOverride 500 pkgs.dash; # pkgs.fish;
  extraGroups = [
    # "audio"
    "disk"
    "video"
    "wheel"
    (mkIf config.virtualisation.libvirtd.enable "docker")
    (mkIf config.virtualisation.libvirtd.enable "libvirtd")
    (mkIf config.networking.networkmanager.enable "networkmanager")
  ];
  openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG3GJXN37jo2h3fRmpOBwk7oiLhloY9qCmyCwG5ml4FC"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAczeNl3H+oLiaZT0jSGS+p4O8dKS14ahBY9qifB9Fqf"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOXX5fjPp6lZYLGAHj6+UmMhE+5bmvAWoOJRqN9Fe9O7"
  ];
  uid = mkDefault 1000;
  subGidRanges = [
    {
      startGid = 100000;
      count = 65536;
    }
  ];
  subUidRanges = [
    {
      startUid = 100000;
      count = 65536;
    }
  ];
}
