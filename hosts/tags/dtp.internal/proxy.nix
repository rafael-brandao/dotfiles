{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.dtp.proxy;
  owner = "tinyproxy";
  group = "tinyproxy";
in {
  options.dtp.proxy = {
    enable =
      mkEnableOption "Wheter to configure dtp proxy"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = config.sops.enable;
        message = "Sops must be enabled to securelly setup upstream proxy";
      }
    ];

    lib.dtp.proxy.url = "http://${config.services.tinyproxy.settings.Listen}:${toString config.services.tinyproxy.settings.Port}";

    networking.proxy.default = config.lib.dtp.proxy.url;

    services.tinyproxy = {
      enable = true;
      includeDefaultCfg = true;
      includes = [
        config.sops.secrets."tinyproxy/tinyproxy-sops.conf".path
      ];
      settings = {
        Listen = mkOverride 500 "127.0.0.1";
        Port = mkOverride 500 8888;
        User = mkForce owner;
        Group = mkForce group;
        upstream = [
          ''none "127.0.0.0/8"''
          ''none "localhost"''
          ''none "10.0.0.0/8"''
          ''none "192.168.0.0/255.255.254.0"''
          ''none "."''
        ];
      };
    };

    sops.secrets."tinyproxy/tinyproxy-sops.conf" = {
      inherit owner group;
      key = "tinyproxy/cfg";
      mode = "0440";
      restartUnits = ["tinyproxy.service"];
      sopsFile = ./secrets.yaml;
    };
  };
}
