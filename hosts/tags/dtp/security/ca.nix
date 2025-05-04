{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.dtp.security.pki;

  # TODO: Move this to a custom lib function
  listRegularFilesIn = dir: let
    filterRegularFiles = filterAttrs (_name: value: value == "regular");
    toFullPaths = flipPipe [
      attrNames
      (map (file: dir + "/${file}"))
    ];
  in
    pipe dir [
      builtins.readDir
      filterRegularFiles
      toFullPaths
    ];
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
