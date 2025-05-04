{
  config,
  lib,
  ...
}:
with lib;
  mkIf config.sops.enable {
    programs.gopass.age = {
      identities = [
        {
          keyType = "ssh";
          privateKeyPath = config.sops.secrets."dtp/ssh/identities/01/id_ed25519".path;
        }
      ];
    };
  }
