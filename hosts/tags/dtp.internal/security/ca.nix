{
  config,
  lib,
  ...
}:
with lib; let
  inherit (local) listRegularFilesIn;
in {
  config = mkIf config.dtp.security.pki.installCACerts {
    security.pki.certificateFiles = listRegularFilesIn ./ca;
  };
}
