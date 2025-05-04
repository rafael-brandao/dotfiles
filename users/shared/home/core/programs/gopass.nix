{
  config,
  lib,
  ...
}:
with lib;
  mkIf config.programs.gopass.enable {
    programs.gopass = {
      enableGitIntegration = mkDefault config.programs.git.enable;
      enableJsonapi = mkDefault true;
      # enableLibSecretIntegration = mkDefault true; # FIX: Exception: could not find .gpg-id file (lib-secret does not support age encryption)
    };
  }
