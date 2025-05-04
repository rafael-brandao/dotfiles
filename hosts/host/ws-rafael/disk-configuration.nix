{
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M"; # BIOS boot partition
              type = "EF02"; # for grub MBR
              priority = 1; # Needs to be first partition
            };
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["rw" "noatime" "fmask=0022" "dmask=0022" "codepage=437" "iocharset=iso8859-1" "shortname=mixed"];
              };
            };
            cryptroot = {
              end = "-8G"; # remaining size until the last 8G
              # type = "primary"; # Primary partition
              content = {
                type = "luks";
                name = "cryptroot";
                passwordFile = "/tmp/secret.key";
                extraOpenArgs = ["--type=luks2"];
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  subvolumes = {
                    "/subvolumes/root" = {
                      mountpoint = "/";
                      mountOptions = ["subvol=subvolumes/root" "noatime" "compress=zstd:3" "space_cache=v2" "ssd" "discard=async"];
                    };
                    "/subvolumes/home" = {
                      mountpoint = "/home";
                      mountOptions = ["subvol=subvolumes/home" "noatime" "compress=zstd:3" "space_cache=v2" "ssd" "discard=async"];
                    };
                    "/subvolumes/nix" = {
                      mountpoint = "/nix";
                      mountOptions = ["subvol=subvolumes/nix" "noatime" "compress=zstd:3" "space_cache=v2" "ssd" "discard=async"];
                    };
                    "/subvolumes/persist" = {
                      mountpoint = "/persist";
                      mountOptions = ["subvol=subvolumes/persist" "noatime" "compress=zstd:3" "space_cache=v2" "ssd" "discard=async"];
                    };
                    "/subvolumes/log" = {
                      mountpoint = "/var/log";
                      mountOptions = ["subvol=subvolumes/log" "noatime" "compress=zstd:3" "space_cache=v2" "ssd" "discard=async"];
                    };
                  };
                };
              };
            };
            cryptswap = {
              size = "100%"; # Use the remaining space for swap
              # type = "primary"; # Primary partition
              content = {
                type = "luks";
                name = "cryptswap";
                passwordFile = "/tmp/secret.key";
                extraOpenArgs = ["--type=luks2"];
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "swap";
                  # mountPoint = "none"; # No mount point needed for swap
                };
              };
            };
          };
        };
      };
    };
  };
}
