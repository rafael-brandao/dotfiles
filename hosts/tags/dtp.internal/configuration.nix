{
  # config,
  ...
}: {
  imports = [
    # ./proxy.nix
    ./security/ca.nix
  ];

  # programs.git.config = {
  #   http.sslBackend = "schannel";
  #   http.sslCAPath = config.environment.etc."ssl/certs/ca-bundle.crt".source;
  #   # http.sslVerify = false;
  # };

  # nix.settings = {
  #   ssl-cert-file = "/etc/ssl/certs/ca-bundle.crt";
  # };
  # security.pki.certificates = [
  #   (builtins.readFile ./security/ca/001.pem)
  # ];

  # environment.sessionVariables = {
  #   CURL_CA_BUNDLE = config.environment.etc."ssl/certs/ca-bundle.crt".source;
  #   GIT_SSL_CAINFO = config.environment.etc."ssl/certs/ca-bundle.crt".source;
  #   NIX_GIT_SSL_CAINFO = config.environment.etc."ssl/certs/ca-bundle.crt".source;
  #   NIX_SSL_CERT_FILE = config.environment.etc."ssl/certs/ca-bundle.crt".source;
  #   SSL_CERT_FILE = config.environment.etc."ssl/certs/ca-bundle.crt".source;
  # };

  # systemd.services.nix-daemon.environment = {
  #   GIT_SSL_CAINFO = config.environment.etc."ssl/certs/ca-bundle.crt".source;
  #   NIX_GIT_SSL_CAINFO = config.environment.etc."ssl/certs/ca-bundle.crt".source;
  #   NIX_SSL_CERT_FILE = config.environment.etc."ssl/certs/ca-bundle.crt".source;
  #   SSL_CERT_FILE = config.environment.etc."ssl/certs/ca-bundle.crt".source;
  # };
}
