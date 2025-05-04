{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.rb.flake;
in {
  options.rb.flake = {
    enable =
      mkEnableOption "Whether or not to enable Nix Flakes configuration"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    nix = {
      package = mkDefault pkgs.nixVersions.latest;
      extraOptions = "experimental-features = nix-command flakes";
      settings.experimental-features = ["nix-command" "flakes"];
    };
  };
}
