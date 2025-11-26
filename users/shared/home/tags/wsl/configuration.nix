{lib, ...}:
with lib; {
  programs = {
    dank-material-shell.enable = mkImageMediaOverride false;
  };
}
