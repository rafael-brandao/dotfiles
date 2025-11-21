{
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
    ./nixvim.nix
    ./starship.nix
    # ./syncrclone.nix

    # Shell
    ./shell/aliases.nix
    ./shell/fish.nix

    # Desktop
    ./ghostty.nix
  ];

  programs = mkMerge [
    {
      # Terminal
      aria2.enable = true;
      atuin.enable = true;
      bat.enable = true;
      delta.enable = true;
      fish.enable = true;
      foot.enable = true;
      git.enable = true;
      gopass.enable = true;
      jujutsu.enable = true;
      neovim.enable = false;
      ripgrep.enable = true;
      starship.enable = true;
      yazi.enable = true;
    }
    ( # Desktop || Workstation || WSL
      mkIf (hostcfg.info.hasAnyTagIn ["desktop" "workstation" "wsl"])
      {
        ghostty.enable = true;
      }
    )
  ];

  home = {
    packages = with pkgs; [
      age
      jq
      ripgrep-all
    ];
  };
}
