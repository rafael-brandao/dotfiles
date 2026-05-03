{lib, ...}:
with lib; {
  programs = {
    dank-material-shell.enable = mkImageMediaOverride false;
  };

  wayland = {
    windowManager.mango.enable = mkImageMediaOverride false;
  };
}
