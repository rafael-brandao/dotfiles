{
  config,
  lib,
  osConfig ? {},
  pkgs,
  ...
}:
with lib;
  mkIf (osConfig == {} || (!osConfig.stylix.enable) || (!osConfig.stylix.homeManagerIntegration.autoImport)) {
    stylix = {
      enable = mkDefault true;
      autoEnable = mkDefault true;
      image = mkDefault ./stylix/wallpaper.jpg;
      scheme = with config.lib.stylix.schemes; mkDefault base16-schemes.catppuccin-mocha;
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
          package = mkDefault noto-fonts-color-emoji;
          name = mkDefault "Noto Color Emoji";
        };
      };
      cursor = {
        package = mkDefault pkgs.bibata-cursors;
        name = mkDefault "Bibata-Modern-Ice";
        size = mkDefault 24;
      };
      icons = {
        enable = mkDefault true;
        package = mkDefault pkgs.papirus-icon-theme;
        dark = mkDefault "Papirus-Dark";
        light = mkDefault "Papirus-Light";
      };
    };
  }
