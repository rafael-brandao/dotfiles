{
  hostcfg,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [
    # Terminal
    ./git.nix
    ./gopass.nix
    # ./neovim.nix
    ./starship.nix
    # ./syncrclone.nix

    # Shell
    ./shell/aliases.nix
    ./shell/fish.nix

    # Desktop
    # ./ghostty.nix
  ];

  programs = mkMerge [
    {
      # Terminal
      aria2.enable = true;
      bat.enable = true;
      fish.enable = true;
      foot.enable = true;
      git.enable = true;
      gopass.enable = true;
      neovim.enable = true;
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

  home.packages = with pkgs; [
    age
    jq
    ripgrep-all
  ];
}
