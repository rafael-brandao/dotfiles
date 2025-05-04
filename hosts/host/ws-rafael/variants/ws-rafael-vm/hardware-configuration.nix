{
  # boot = {
  #   extraModulePackages = [];
  #   initrd = {
  #     availableKernelModules = ["ahci" "xhci_pci" "sr_mod"];
  #     kernelModules = [];
  #   };
  #   kernelModules = ["kvm-intel"];
  # };

  fileSystems = {
    "/" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [
        "subvol=subvolumes/root"
        "noatime"
        "compress=zstd:3"
        "space_cache=v2"
        "ssd"
        "discard=async"
      ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/FF67-0C4B";
      fsType = "vfat";
      options = [
        "noatime"
        "fmask=0022"
        "dmask=0022"
        "codepage=437"
        "iocharset=iso8859-1"
        "shortname=mixed"
      ];
    };

    "/home" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [
        "subvol=subvolumes/home"
        "noatime"
        "compress=zstd:3"
        "space_cache=v2"
        "ssd"
        "discard=async"
      ];
    };

    "/nix" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [
        "subvol=subvolumes/nix"
        "noatime"
        "compress=zstd:3"
        "space_cache=v2"
        "ssd"
        "discard=async"
      ];
    };

    "/persist" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [
        "subvol=subvolumes/persist"
        "noatime"
        "compress=zstd:3"
        "space_cache=v2"
        "ssd"
        "discard=async"
      ];
    };

    "/var/log" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [
        "subvol=subvolumes/log"
        "noatime"
        "compress=zstd:3"
        "space_cache=v2"
        "ssd"
        "discard=async"
      ];
    };
  };

  swapDevices = [
    {
      device = "/dev/mapper/cryptswap";
    }
  ];
}
