{
  config,
  lib,
  ...
}:
with lib;
  mkIf config.sops.enable (
    let
      inherit (config.sops) secrets;
    in {
      programs.keychain = {
        keys = [
          secrets."dtp/ssh/identities/01/id_ed25519".path
        ];
      };

      services.map-ssh-identities.identities = [
        {
          identityFile = secrets."dtp/ssh/identities/01/identity".path;
          privateKeyPath = secrets."dtp/ssh/identities/01/id_ed25519".path;
          publicKeyPath = secrets."dtp/ssh/identities/01/id_ed25519.pub".path;
        }
      ];
    }
  )
