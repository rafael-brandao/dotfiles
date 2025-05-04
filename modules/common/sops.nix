{
  config,
  hostcfg,
  lib,
  ...
}:
with lib; {
  options.sops = {
    enable =
      mkEnableOption "Whether or not to enable SOPS Nix"
      // {
        default = ! (hostcfg.info.hasTag "iso");
      };
  };
  config = {
    assertions = [
      {
        assertion = hostcfg.info.hasTag "iso" || config.sops.enable;
        message = "Sops must be enabled if the build is not labeled as 'iso'";
      }
    ];
  };
}
