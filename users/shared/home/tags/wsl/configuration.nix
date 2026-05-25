{lib, ...}:
with lib; {
  programs = {
    dank-material-shell.enable = mkImageMediaOverride false;
  };
  services = {
    kanata.generateKbdFilesOnly = mkOverride 500 true;
  };
  wayland = {
    windowManager.mango.enable = mkImageMediaOverride false;
  };
}
