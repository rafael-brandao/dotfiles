{
  lib,
  osConfig ? {},
  ...
}:
with lib; {
  imports = [
    ./lib/utils.nix
    ./misc/stylix.nix
  ];

  nixpkgs = mkIf (osConfig == {} || !osConfig.home-manager.useGlobalPkgs) {
    config = {
      allowBroken = mkDefault false;
      allowUnfree = mkDefault true;
    };
  };
}
