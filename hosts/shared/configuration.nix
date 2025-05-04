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

            systemPackages = with pkgs;
              mkMerge [
                [
                  curl
                  coreutils
                  gnugrep
                  neovim
                  ripgrep-all
                  rsync
                  wget
                ]
                (mkIf config.hardware.graphics.enable [
                  glxinfo
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
            useGlobalPkgs = mkDefault true;
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
              useDHCP = mkDefault (hostcfg.info.hasTag "vm");
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
        (mkIf (hostcfg.info.runtimePlatformIsOneOf ["iso" "virtual-machine"]) {
          services = {
            openssh = {
              enable = mkDefault true;
              settings = {
                PermitRootLogin = mkOverride 500 "yes";
              };
            };
          };
          users = {
            users.root = {
              openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG3GJXN37jo2h3fRmpOBwk7oiLhloY9qCmyCwG5ml4FC"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAczeNl3H+oLiaZT0jSGS+p4O8dKS14ahBY9qifB9Fqf"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOXX5fjPp6lZYLGAHj6+UmMhE+5bmvAWoOJRqN9Fe9O7"
              ];
            };
          };
        })

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
            kmscon = {
              enable = mkDefault true;
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
          nixosSharedUserConfiguration = "${usercfg.path}/nixos/shared/user-configuration.nix";
          nixosHostUserConfiguration = "${usercfg.path}/nixos/hosts/${hostcfg.host}/user-configuration.nix";
          nixosUsercfg = mkMerge [
            {
              home = mkDefault usercfg.homeDirectory;
              isNormalUser = mkDefault true;
            }
            ((import nixosSharedUserConfiguration) usercfg args)
            (mkIf (pathExists nixosHostUserConfiguration) ((import nixosHostUserConfiguration) usercfg args))
          ];
          homeUsercfg = mkMerge (lib.local.project.getUserHomeModules usercfg);
        in
          mkMerge [
            {
              home-manager.users.${usercfg.username} = homeUsercfg;
              users.users.${usercfg.username} = nixosUsercfg;
            }
            (mkIf config.sops.enable {
              sops.secrets = let
                sopsFile = usercfg.path + /nixos/shared/secrets.yaml;
              in {
                "users/${usercfg.username}/ageKey" = {
                  key = mkDefault "ageKey";
                  neededForUsers = mkForce true;
                  sopsFile = mkDefault sopsFile;
                };
                "users/${usercfg.username}/hashedPassword" = {
                  key = mkDefault "hashedPassword";
                  neededForUsers = mkForce true;
                  sopsFile = mkDefault sopsFile;
                };
              };

              users.users.${usercfg.username} = {
                hashedPasswordFile = mkDefault config.sops.secrets."users/${usercfg.username}/hashedPassword".path;
              };

              system.activationScripts."sopsSetAgeKeysFor_${usercfg.username}" = let
                inherit (usercfg) username;
                ageFolder = config.users.users."${username}".home + "/.config/sops/age";
                ageFile = "${ageFolder}/keys.txt";
              in
                # bash
                ''
                  # Create directory tree and set permissions up to /home/${username}
                  current_dir="${ageFolder}"
                  while [ "''$current_dir" != "/home/${username}" ] && [ "''$current_dir" != "/" ]; do
                    mkdir -p "''$current_dir" || true
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
