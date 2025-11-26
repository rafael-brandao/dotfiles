{
  disko.devices = {
    disk = {
      disk0 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["noatime" "umask=0077"];
              };
            };
            cryptroot = {
              end = "-8G"; # remaining size until the last 8G
              content = {
                type = "luks";
                name = "cryptroot";
                passwordFile = "/tmp/cryptroot-secret.key";
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
              content = {
                type = "luks";
                name = "cryptswap";
                passwordFile = "/tmp/cryptswap-secret.key";
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
