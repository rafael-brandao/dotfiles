{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.keychain;
in {
  programs.keychain = {
    enable = mkIf (length cfg.keys > 0) (mkDefault true);
    keys = [];
  };
}
