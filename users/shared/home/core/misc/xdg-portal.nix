{
  hostcfg,
  lib,
  pkgs,
  ...
}:
with lib;
  mkIf (hostcfg.info.hasAnyTagIn ["desktop" "workstation" "wsl"]) {
    xdg.portal = {
      enable = mkDefault true;
      extraPortals = with pkgs;
        mkAfter [
          xdg-desktop-portal-gtk
        ];
      configPackages = with pkgs;
        mkAfter [
          xdg-desktop-portal-gtk
        ];
      xdgOpenUsePortal = mkDefault true;
      config = {
        common = {
          default = mkAfter ["gtk"];
        };
      };
    };
  }
# [portal]
# DBusName=org.freedesktop.impl.portal.desktop.gtk
# Interfaces=org.freedesktop.impl.portal.FileChooser;org.freedesktop.impl.portal.AppChooser;org.freedesktop.impl.portal.Print;org.freedesktop.impl.portal.Notification;org.freedesktop.impl.portal.Inhibit;org.freedesktop.impl.portal.Access;org.freedesktop.impl.portal.Account;org.freedesktop.impl.portal.Email;org.freedesktop.impl.portal.DynamicLauncher;org.freedesktop.impl.portal.Lockdown;org.freedesktop.impl.portal.Settings;org.freedesktop.impl.portal.Wallpaper;
# UseIn=gnome
# [portal]
# DBusName=org.freedesktop.impl.portal.desktop.hyprland
# Interfaces=org.freedesktop.impl.portal.Screenshot;org.freedesktop.impl.portal.ScreenCast;org.freedesktop.impl.portal.GlobalShortcuts;
# UseIn=wlroots;Hyprland;sway;Wayfire;river;

