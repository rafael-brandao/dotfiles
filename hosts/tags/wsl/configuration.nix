{
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = with inputs; [
    nixos-wsl.nixosModules.wsl
  ];

  # networking.useHostResolvConf = false;
  wsl = {
    enable = mkDefault true;
    defaultUser = mkDefault "nixos";
    # docker.enable = mkDefault true; # Enable integration with Docker Desktop (needs to be installed)
    startMenuLaunchers = mkDefault true;
    wslConf.automount.root = mkDefault "/mnt";

    #   The option definition `wsl.nativeSystemd' in `/nix/store/3nsblbgn2g2dp3pga0bm8g29pg1ns3kj-labels/wsl.nix'
    # no longer has any effect; please remove it.
    #   Native systemd is now always enabled as support for syschdemd has been removed
    # nativeSystemd = mkDefault true;
  };

  lib.wsl = {
    nameserver = "$(${pkgs.gnugrep}/bin/grep nameserver /etc/resolv.conf | ${pkgs.gnused}/bin/sed 's/nameserver //')";
  };

  environment.sessionVariables = {
    # MESA_D3D12_DEFAULT_ADAPTER_NAME = "NVIDIA";
    DISPLAY = mkDefault ":0";
    # LIBGL_ALWAYS_INDIRECT = "1";
    # PULSE_SERVER = "tcp:${nameserver}";
  };

  hardware = {
    graphics = {
      enable = mkDefault true;
      enable32Bit = mkDefault true;
    };
  };

  programs = {
    gnupg = {
      agent = {
        enable = mkDefault true;
        enableBrowserSocket = mkDefault true;
        enableExtraSocket = mkDefault true;
        enableSSHSupport = mkDefault true;
        pinentryPackage = mkDefault pkgs.pinentry-curses;
      };
    };
  };
}
# (mkIf hostcfg.isWsl {
#   environment.sessionVariables =
#     let nameserver = "$(${pkgs.gnugrep}/bin/grep nameserver /etc/resolv.conf | ${pkgs.gnused}/bin/sed 's/nameserver //')"; in
#     {
#       DISPLAY = "${nameserver}:0.0";
#       PULSE_SERVER = "tcp:${nameserver}";
#     };
#   services.xserver.displayManager = {
#     defaultSession = "homemanager";
#     startx.enable = true;
#   };
# })

