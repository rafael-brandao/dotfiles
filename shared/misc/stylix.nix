{
  lib,
  pkgs,
  ...
}:
with lib; let
  themeName = "rose-pine";

  themeOverrides = {
    rose-pine = {
      base02 = "4e486e";
    };
  };
in {
  stylix = {
    enable = mkDefault true;
    autoEnable = mkDefault true;

    # fonts = mkRecursiveDefault fonts;
    fonts = with pkgs; {
      monospace = {
        package = mkDefault nerd-fonts.intone-mono;
        name = mkDefault "IntoneMono Nerd Font Mono";
      };
      serif = {
        package = mkDefault dejavu_fonts;
        name = mkDefault "DejaVu Serif";
      };
      sansSerif = {
        package = mkDefault dejavu_fonts;
        name = mkDefault "DejaVu Sans";
      };
      emoji = {
        package = mkDefault noto-fonts-emoji;
        name = mkDefault "Noto Color Emoji";
      };
    };
    image = mkDefault ./stylix/wallpaper.jpg;
    override = mkDefault themeOverrides.${themeName} or {};
  };
}
