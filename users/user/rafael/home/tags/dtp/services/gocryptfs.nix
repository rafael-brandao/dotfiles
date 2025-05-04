{
  config,
  lib,
  ...
}:
with lib; let
  inherit (config.sops) secrets;
in
  mkIf config.sops.enable {
    services.gocryptfs.mounts.dtp = {
      configFile = secrets."dtp/gocryptfs/mounts/01/gocryptfs.conf".path;
      passwordFile = secrets."dtp/gocryptfs/mounts/01/passfile".path;
      cypherDirectoryPath = "${config.xdg.dataHome}/gocryptfs/dtp/01";
      plainDirectoryPath = "${config.home.homeDirectory}/Dataprev";
    };
  }
