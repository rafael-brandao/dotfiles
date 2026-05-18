{
  config,
  hostcfg,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [
    # Terminal
    ./atuin.nix
    ./delta.nix
    ./git.nix
    ./gopass.nix
    ./jujutsu.nix
    ./nvf.nix
    ./starship.nix
    # ./syncrclone.nix

    # Shell
    ./shell/aliases.nix
    ./shell/fish.nix

    # Desktop
    ./ghostty.nix
    # ./wezterm.nix
  ];

  programs = mkMerge [
    {
      # Terminal
      aria2.enable = true;
      atuin.enable = true;
      bat.enable = true;
      delta.enable = true;
      fish.enable = true;
      git.enable = true;
      gopass.enable = true;
      jujutsu.enable = true;
      nvf.enable = true;
      ripgrep.enable = true;
      starship.enable = true;
      yazi.enable = true;
    }
    ( # Desktop || Workstation || WSL
      mkIf (hostcfg.info.hasAnyTagIn ["desktop" "workstation" "wsl"])
      {
        ghostty.enable = true;
        wezterm.enable = true;
      }
    )
  ];

  home = {
    packages = with pkgs; [
      age
      devenv
      jq
      ripgrep-all
    ];
  };

  rb.defaults.apps = {
    editor = {
      name = "nvf";
      command = "nvim";
      desktopFileId = "nvim.desktop";
      package = config.programs.nvf.finalPackage;
      settings = {
        home = {
          autoEnableProgram = false;
          installPackage = false;
        };
        xdgMime.priority = "high";
      };
    };
    fileManager = {
      settings.xdgMime.priority = "high";
    };
  };
}
