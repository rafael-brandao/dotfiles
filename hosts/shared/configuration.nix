{
  config,
  hostcfg,
  inputs,
  lib,
  pkgs,
  ...
} @ args:
with lib; let
  defaults = {
    kernelPackage = pkgs.linuxPackages_latest;
    keymap = "br-abnt2";
  };
in {
  config =
    mkMerge
    (
      [
        {
          environment = {
            enableAllTerminfo = mkDefault true;

            # From https://github.com/nix-community/home-manager/blob/master/modules/misc/xdg-portal.nix
            # If you use the NixOS module and have `useUserPackages = true`
            pathsToLink = mkIf config.home-manager.useUserPackages ["/share/xdg-desktop-portal" "/share/applications"];

            systemPackages = with pkgs;
              mkMerge [
                [
                  clevis
                  coreutils
                  curl
                  evtest
                  gnugrep
                  neovim
                  pciutils
                  ripgrep-all
                  rsync
                  wget
                ]
                (mkIf config.hardware.graphics.enable [
                  kanshi
                  mangohud
                  mesa-demos
                  wlr-randr
                ])
              ];
          };

          hardware = {
            enableAllFirmware = mkDefault true;
            enableRedistributableFirmware = mkDefault true;
          };

          home-manager = {
            backupFileExtension = "backup";
            extraSpecialArgs = {
              inherit inputs;
              inherit (lib.local) paths;
              hostcfg = removeAttrs hostcfg ["users"];
            };
            useGlobalPkgs = mkDefault config.stylix.enable;
            useUserPackages = mkDefault true;
          };

          i18n = {
            defaultLocale = mkDefault "en_US.UTF-8"; # Select internationalization properties.
            defaultCharset = mkDefault "UTF-8";
            supportedLocales = ["en_US.UTF-8/UTF-8" "pt_BR.UTF-8/UTF-8"];
          };

          networking = mkMerge [
            {
              enableIPv6 = mkDefault false;
              hostName = mkDefault hostcfg.hostname;

              # The global useDHCP flag is deprecated, therefore explicitly set to false here.
              # Per-interface useDHCP will be mandatory in the future, so this generated config
              # replicates the default behaviour.
              # useDHCP = mkDefault false;
              useDHCP = mkDefault (hostcfg.info.hasTag "virtual-machine");
            }
            (mkIf (!config.networking.wireless.enable) {
              networkmanager = {
                enable = mkDefault true;
                plugins = [pkgs.networkmanager-strongswan];
              };
            })
          ];

          nix = {
            gc = {
              automatic = true;
              dates = "weekly";
              # Delete older generations too
              options = "--delete-older-than 7d";
            };

            # Add nixpkgs input to NIX_PATH
            # This lets nix2 commands still use <nixpkgs>
            nixPath = ["nixpkgs=${inputs.nixpkgs}"];

            # Add each flake input as a registry
            # To make nix3 commands consistent with the flake
            registry = mapAttrs (_: value: {flake = value;}) inputs;

            settings = {
              auto-optimise-store = mkDefault true;
              flake-registry = mkDefault ""; # Disable global flake registry
              trusted-users = ["root" "@wheel"];
              warn-dirty = mkDefault false;
            };
          };

          nixpkgs = {
            hostPlatform = mkDefault hostcfg.system;
            overlays = lib.attrValues inputs.self.overlays;
          };

          programs = {
            fish.enable = mkDefault true;
            fuse.userAllowOther = mkDefault true;
            git.enable = mkDefault true;
          };

          security = {
            rtkit.enable = mkDefault true; # rtkit is optional but recommended
          };

          services = {
            openssh = {
              enable = mkDefault true;
              settings = {
                PasswordAuthentication = mkDefault false;
                PermitRootLogin = mkDefault "no";
              };
            };
          };

          system = {
            # autoUpgrade = {
            #   enable = mkDefault true;
            #   allowReboot = mkDefault false;
            #   channel = mkDefault "https://nixos.org/channels/nixos-unstable";
            # };

            # This value determines the NixOS release from which the default
            # settings for stateful data, like file locations and database versions
            # on your system were taken. It‘s perfectly fine and recommended to leave
            # this value at the release version of the first install of this system.
            # Before changing this value read the documentation for this option
            # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
            stateVersion = mkOverride 500 "25.05"; # Did you read the comment?
          };

          time = {
            timeZone = mkDefault "America/Sao_Paulo"; # Set your time zone.
          };

          users = {
            mutableUsers = mkDefault false;
          };
        }

        (mkIf config.sops.enable {
          sops = {
            age = {
              sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
              keyFile = mkDefault "/var/lib/sops-nix/key.txt";
              generateKey = mkDefault true;
            };
            defaultSopsFile = mkDefault (hostcfg.sops.path + /secrets.yaml);
            gnupg.sshKeyPaths = [];
            validateSopsFiles = mkDefault true;
          };
        })

        (mkIf (! hostcfg.info.hasAnyTagIn ["wsl"]) {
          boot = {
            kernelPackages = mkIf (!hostcfg.info.hasTag "iso") (mkOverride 500 pkgs.linuxPackages_latest);
            kernelParams = ["console-keymap=${config.console.keyMap}"];
            loader = with config.boot.loader; {
              efi = mkIf (efi.canTouchEfiVariables || (grub.enable && grub.efiSupport)) {
                efiSysMountPoint = mkDefault "/boot";
              };
              grub = mkIf grub.enable {
                efiSupport = mkDefault efi.canTouchEfiVariables;
                # enableCryptodisk = mkDefault config.boot.loader.supportsInitrdSecrets;
              };
              systemd-boot = mkIf systemd-boot.enable {
                consoleMode = mkDefault "max";
                memtest86.enable = mkDefault true;
              };
            };
          };

          console = {
            earlySetup = mkDefault true;
            # High-DPI console
            # font = mkDefault lib.mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
            # font = mkDefault "Lat2-Terminus16";
            font = mkDefault "spleen-8x16";
            keyMap = mkDefault defaults.keymap;
            packages = [pkgs.spleen];
            useXkbConfig = mkDefault config.services.xserver.enable;
          };

          services = {
            getty = {
              autologinOnce = mkIf (config.services.getty.autologinUser != null) (mkDefault true);
            };
            kmscon = {
              # enable = mkDefault true;
              hwRender = mkDefault true;
              # hwRender = mkDefault config.hardware.graphics.enable; # This produces infinite recursion error
              fonts = mkDefault [
                {
                  name = "SauceCodePro Nerd Font";
                  package = pkgs.nerd-fonts.sauce-code-pro;
                }
              ];
              # TODO: Externalize xkb-layout and xkb-variant
              extraConfig = ''
                xkb-layout=br
                xkb-variant=abnt2
              '';
              extraOptions = mkDefault "--term vt220";
              # extraOptions = mkDefault "--term vt510";
              # extraOptions = mkDefault "--term xterm-256color";
            };
          };
        })
      ]
      ++ (forEach (attrValues hostcfg.userSettings) (
        usercfg: let
          inherit (usercfg) username;
          nixosSharedUserConfiguration = "${usercfg.path}/nixos/shared/user-configuration.nix";
          nixosHostUserConfiguration = "${usercfg.path}/nixos/hosts/${hostcfg.host}/user-configuration.nix";
          nixosUsercfg = mkMerge [
            {
              home = mkForce usercfg.homeDirectory;
              isNormalUser = mkDefault true;
            }
            ((import nixosSharedUserConfiguration) usercfg args)
            (mkIf (pathExists nixosHostUserConfiguration) ((import nixosHostUserConfiguration) usercfg args))
          ];
          userHomeModules = lib.local.project.getUserHomeModules usercfg;
          optionalUserHomeModules = [
            (mkIf (!config.home-manager.useGlobalPkgs) inputs.stylix.homeModules.stylix)
          ];
          homeUsercfg = mkMerge (userHomeModules ++ optionalUserHomeModules);
        in
          mkMerge [
            {
              home-manager.users.${usercfg.username} = homeUsercfg;
              users.users.${usercfg.username} = nixosUsercfg;

              # TODO: check the necessity to apply this onlly when home.userGlobalPackages = true
              system.activationScripts."fixHomeNixProfileFor_${usercfg.username}" = let
                inherit (config.users.users."${username}") home;
              in ''
                nix_profiles_dir="${home}/.local/state/nix/profiles"
                mkdir --parents "''$nix_profiles_dir" || true

                # Set permissions up to ${home}
                current_dir="''$nix_profiles_dir"
                while [ "''$current_dir" != "${home}" ] && [ "''$current_dir" != "/" ]; do
                chown "$(id --user ${username})":"$(id --group ${username})" "''$current_dir"
                  current_dir=$(dirname "''$current_dir")
                done

                rm --force "''${nix_profiles_dir}/profile"
                ln --symbolic /etc/profiles/per-user/${username} "''${nix_profiles_dir}/profile"
              '';
            }

            (mkIf config.sops.enable {
              sops.secrets = let
                sopsFile = usercfg.path + /nixos/shared/secrets.yaml;
              in {
                "users/${username}/ageKey" = {
                  key = mkDefault "ageKey";
                  neededForUsers = mkForce true;
                  sopsFile = mkDefault sopsFile;
                };
                "users/${username}/hashedPassword" = {
                  key = mkDefault "hashedPassword";
                  neededForUsers = mkForce true;
                  sopsFile = mkDefault sopsFile;
                };
              };

              users.users.${username} = {
                hashedPasswordFile = mkDefault config.sops.secrets."users/${username}/hashedPassword".path;
              };

              system.activationScripts."sopsSetAgeKeysFor_${username}" = let
                ageFolder = config.users.users."${username}".home + "/.config/sops/age";
                ageFile = "${ageFolder}/keys.txt";
              in
                # bash
                ''
                  # Create directory tree and set permissions up to /home/${username}
                  current_dir="${ageFolder}"
                  while [ "''$current_dir" != "/home/${username}" ] && [ "''$current_dir" != "/" ]; do
                    mkdir --parents "''$current_dir" || true
                    chown ${username}:users "''$current_dir"
                    current_dir=$(dirname "''$current_dir")
                  done
                  touch ${ageFile}
                  chown ${username}:users ${ageFile}
                  chmod 600 ${ageFile}
                  cat ${config.sops.secrets."users/${usercfg.username}/ageKey".path} > ${ageFile}
                  if groups ${username} | grep "wheel" > /dev/null; then
                    printf "\n" >> ${ageFile}
                    cat /etc/ssh/ssh_host_ed25519_key | ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key >> ${ageFile}
                  fi
                '';
            })
          ]
      ))
    );
}
