{
  config,
  lib,
  ...
}:
with lib; let
  inherit (config.sops) secrets;
in
  mkIf config.sops.enable {
    services.gocryptfs.mounts.default = {
      configFile = secrets."gocryptfs/mounts/01/gocryptfs.conf".path;
      passwordFile = secrets."gocryptfs/mounts/01/passfile".path;
      cypherDirectoryPath = "${config.xdg.dataHome}/gocryptfs/default/01";
      plainDirectoryPath = "${config.home.homeDirectory}/Personal";
    };
  }
