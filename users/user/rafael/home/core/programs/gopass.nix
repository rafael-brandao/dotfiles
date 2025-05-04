{
  config,
  lib,
  ...
}:
with lib; let
  inherit (config.sops) secrets;
in
  mkIf config.sops.enable {
    programs.gopass = {
      age = {
        identities = [
          {
            keyType = "ssh";
            privateKeyPath = secrets."ssh/identities/01/id_ed25519".path;
          }
        ];
        passwordFile = secrets."gopass/age/recipientsPassword".path;
      };
    };
  }
