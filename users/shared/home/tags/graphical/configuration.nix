{lib, ...}:
with lib; {
  gtk.enable = mkOverride 1490 true;
  qt.enable = mkOverride 1490 true;

  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = mkOverride 1490 "qt6ct";
  };

  stylix.targets.qt.platform = mkOverride 1490 "qt6ct";

  xdg.configFile = {
    "gtk-3.0/gtk.css".force = mkOverride 1490 true;
    "gtk-4.0/gtk.css".force = mkOverride 1490 true;
  };
}
