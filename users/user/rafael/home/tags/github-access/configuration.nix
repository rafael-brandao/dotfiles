{
  config,
  lib,
  ...
}:
with lib;
  mkIf config.sops.enable {
    sops.secrets = {
      "nix/extraOptions/access-tokens/github" = {
        sopsFile = ./secrets.yaml;
      };
    };

    nix.extraOptions = ''
      !include ${config.sops.secrets."nix/extraOptions/access-tokens/github".path}
    '';
  }
