{
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = local.defaults;
in {
  options.local.defaults = {

  };
}
  # defaults = let
  #   # Define locale-specific settings for keymap, xkbLayout, and xkbVariant
  #   localeSettingsMap = rec {
  #     defaults = en_US;
  #     en_US = {
  #       locale = "en_US";
  #       keymap = "us";
  #       xkbLayout = "us";
  #       xkbVariant = "";
  #     };
  #     pt_BR = {
  #       locale = "pt_BR";
  #       keymap = "br-abnt2";
  #       xkbLayout = "br";
  #       xkbVariant = "abnt2";
  #     };
  #   };
  # in rec {
  #   inherit
  #     (localeSettingsMap.defaults)
  #     locale
  #     keymap
  #     xkbLayout
  #     xkbVariant
  #     ;
  #   encoding = "UTF-8";
  #   kernelPackage = pkgs.linuxPackages_latest;
  #   supportedEncodings = ["UTF-8"];
  #   supportedLocales = mapCartesianProduct ({
  #     locale,
  #     encoding,
  #   }: "${locale}.${encoding}/${encoding}") {
  #     locale = pipe localeSettingsMap [(flip removeAttrs ["defaults"]) attrNames];
  #     encoding = supportedEncodings;
  #   };
  # };
