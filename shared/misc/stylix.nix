{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
with lib;
  mkMerge [
    {
      stylix = {
        enable = mkDefault true;
      };
    }
    (mkIf (osConfig == {} && config.stylix.enable) {
      stylix = {
        autoEnable = mkDefault true;
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
        polarity = mkDefault "dark";
      };
    })
  ]
