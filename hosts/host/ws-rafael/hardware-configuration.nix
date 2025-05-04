_: {
  boot = {
    extraModprobeConfig = ''
      options kvm_intel nested=1
      options kvm_intel emulate_invalid_guest_state=0
      options kvm ignore_msrs=1
    '';
    extraModulePackages = [];
    initrd = {
      availableKernelModules = [
        "aesni_intel"
        "ahci"
        "cryptd"
        "ehci_pci"
        "sd_mod"
        "uas"
        "usb_storage"
        "usbhid"
        "xhci_pci"
      ];
      kernelModules = ["kvm-intel"];
    };
    kernelParams = [
      "amdgpu.force_probe=0x57"
      "i915.force_probe=0xa5"
    ];
  };

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
      # device = "/dev/disk/by-label/EFI"; # now taken care by disko
      device = "/dev/disk/by-label/EFI";
      fsType = "vfat";
      options = [
        "rw"
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

    # "/backup" = {
    #   device = "/dev/mapper/BACKUP";
    #   fsType = "btrfs";
    #   options =
    #     [
    #       "ro"
    #       "subvol=/"
    #       "noatime"
    #       "compress=zstd:3"
    #       "space_cache=v2"
    #       "nossd"
    #     ];
    # };

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
      neededForBoot = true;
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
      neededForBoot = true;
    };
  };

  swapDevices = [
    {
      device = "/dev/mapper/cryptswap";
    }
  ];

  networking.interfaces = {
    enp3s0.useDHCP = true;
    enp7s0f0.useDHCP = true;
    enp7s0f1.useDHCP = true;
    wlp6s0.useDHCP = true;
  };
}
