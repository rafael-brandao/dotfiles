{
  config,
  lib,
  ...
}:
with lib; let
  inherit (local) listRegularFilesIn;
  cfg = config.dtp.security.pki;
in {
  options.dtp.security.pki = {
    installCACerts =
      mkEnableOption "Install dtp CA certificates to the system"
      // {
        default = true;
      };
  };

  config = mkIf cfg.installCACerts {
    # Convert DER format to PEM
    # https://stackoverflow.com/a/7397550
    security.pki.certificateFiles = listRegularFilesIn ./ca;
  };
}
