{
  osConfig,
  lib,
  ...
}:
with lib; let
  caPath =
    attrByPath
    ["systemd" "services" "nix-daemon" "environment" "REQUESTS_CA_BUNDLE"]
    "/etc/ssl/certs/ca-certificates.crt"
    osConfig;
in {
  home.sessionVariables = {
    REQUESTS_CA_BUNDLE = mkOverride 1490 caPath;
  };
}
