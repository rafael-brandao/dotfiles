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
          secrets."ssh/identities/01/id_ed25519".path
        ];
      };

      services.map-ssh-identities.identities = [
        {
          identityFile = secrets."ssh/identities/01/identity".path;
          privateKeyPath = secrets."ssh/identities/01/id_ed25519".path;
          publicKeyPath = secrets."ssh/identities/01/id_ed25519.pub".path;
        }
      ];
    }
  )
