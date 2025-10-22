{
  config,
  hostcfg,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (config.lib) usercfg;
in {
  imports = [
    ./programs
  ];

  config = mkMerge [
    {
      home = {
        username = mkDefault usercfg.username;
        homeDirectory = mkDefault usercfg.homeDirectory;

        packages = with pkgs; [
          aria2 # A lightweight, multi-protocol, multi-source, command-line download utility
          wget #  Tool for retrieving files using HTTP, HTTPS, and FTP
        ];

        # You can update Home Manager without changing this value. See
        # the Home Manager release notes for a list of state version
        # changes in each release.
        stateVersion = mkDefault "25.05";
      };

      programs = {
        btop.enable = mkDefault true;
        dircolors.enable = mkDefault true;
        direnv.enable = mkDefault true;
        direnv.nix-direnv.enable = mkDefault true;
        home-manager.enable = mkForce true; # Let Home Manager install and manage itself
        htop.enable = mkDefault true;
        neovim.enable = mkDefault true;
        starship.enable = mkDefault true;
        zoxide.enable = mkDefault true;
      };

      sops = mkIf config.sops.enable {
        age.keyFile = mkDefault "${config.xdg.configHome}/sops/age/keys.txt";
        defaultSopsFile = mkDefault (usercfg.path + /home/hosts/host/${hostcfg.sops.host}/secrets.yaml);
        validateSopsFiles = mkDefault true;
        secrets = {
          "ssh/id_ed25519" = {
            path = "${config.home.homeDirectory}/.ssh/id_ed25519";
            mode = "0600";
          };
          "ssh/id_ed25519.pub" = {
            path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
            mode = "0644";
          };
        };
      };
    }
    # (mkIf hostcfg.isNixos {
    #   home.activation.fixUserNixProfileLink = hm.dag.entryAfter ["writeBoundary"] ''
    #     mkdir --parents ${config.home.homeDirectory}/.local/state/nix/profiles
    #     ln --symbolic --force /etc/profiles/per-user/${usercfg.username} ${config.home.homeDirectory}/.local/state/nix/profiles/profile
    #     ln --symbolic --force ${config.home.homeDirectory}/.local/state/nix/profiles/profile ${config.home.homeDirectory}/.nix-profile
    #   '';
    # })
    (mkIf (hostcfg.info.hasAnyTagIn ["desktop" "workstation"]) {
      home.packages = with pkgs; [
        scribus # Desktop Publishing (DTP) and Layout program
      ];
    })
    (mkIf (hostcfg.info.hasAnyTagIn ["desktop" "workstation" "wsl"]) {
      xdg = {
        enable = mkDefault true;
        mime.enable = mkDefault true;
        mimeApps.enable = mkDefault true;

        # TODO: configure xdg portal
        # Setting xdg.portal.enable to true requires a portal implementation in xdg.portal.extraPortals
        # such as xdg-desktop-portal-gtk or xdg-desktop-portal-kde.
        # portal.enable = mkDefault true;

        userDirs.enable = mkDefault true;
      };
    })
    (mkIf config.xdg.mimeApps.enable {
      home.packages = with pkgs; [
        xdg-launch
        xdg-utils
      ];
    })
    (mkIf config.xdg.portal.enable {
      xdg.portal.xdgOpenUsePortal = mkDefault true;
    })
  ];
}
