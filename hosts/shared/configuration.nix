{
  config,
  hostcfg,
  inputs,
  lib,
  pkgs,
  ...
} @ args:
with lib; let
  defaults = let
    # Define locale-specific settings for keymap, xkbLayout, and xkbVariant
    localeSettingsMap = rec {
      defaults = en_US;
      en_US = {
        locale = "en_US";
        keymap = "us";
        xkbLayout = "us";
        xkbVariant = "";
      };
      pt_BR = {
        locale = "pt_BR";
        keymap = "br-abnt2";
        xkbLayout = "br";
        xkbVariant = "abnt2";
      };
    };
  in rec {
    inherit
      (localeSettingsMap.defaults)
      locale
      keymap
      xkbLayout
      xkbVariant
      ;
    encoding = "UTF-8";
    kernelPackage = pkgs.linuxPackages_latest;
    supportedEncodings = ["UTF-8"];
    supportedLocales = mapCartesianProduct ({
      locale,
      encoding,
    }: "${locale}.${encoding}/${encoding}") {
      locale = pipe localeSettingsMap [(flip removeAttrs ["defaults"]) attrNames];
      encoding = supportedEncodings;
    };
  };
in {
  config =
    mkMerge
    (
      [
        {
          lib = {
            inherit defaults;
          };

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
              inherit inputs paths;
              hostcfg = removeAttrs hostcfg ["users"];
            };
            useGlobalPkgs = mkDefault true;
            useUserPackages = mkDefault true;
          };

          i18n = {
            inherit (defaults) supportedLocales;
            defaultLocale = with defaults; mkDefault "${locale}.${encoding}";
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
            kernelPackages = mkIf (!hostcfg.info.hasTag "iso") (mkOverride 500 defaults.kernelPackage);
            kernelParams = ["console-keymap=${defaults.keymap}"];
            loader = with config.boot.loader; {
              efi = mkIf (efi.canTouchEfiVariables || (grub.enable && grub.efiSupport)) {
                efiSysMountPoint = mkDefault "/boot";
              };
              grub = mkIf grub.enable {
                efiSupport = mkDefault efi.canTouchEfiVariables;
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
              extraConfig = with defaults;
                mkDefault ''
                  xkb-layout=${xkbLayout}
                  xkb-variant=${xkb-variant}
                '';
              extraOptions = mkDefault "--term xterm-256color";
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
                  mkdir --parents ${ageFolder} || true
                  touch ${ageFile}
                  cat ${config.sops.secrets."users/${usercfg.username}/ageKey".path} > ${ageFile}
                  if groups ${username} | grep "wheel" > /dev/null; then
                    printf "\n" >> ${ageFile}
                    cat /etc/ssh/ssh_host_ed25519_key | ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key >> ${ageFile}
                  fi
                  chown --recursive ${username}:users ${ageFolder}
                  chmod 600 ${ageFile}
                '';
            })
          ]
      ))
    );
}
