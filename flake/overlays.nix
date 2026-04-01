{
  inputs,
  lib,
  ...
}:
with lib; let
  overlays = {
    additions = final: _: let
      inherit (final.stdenv.hostPlatform) system;
    in {
      stable = mkPkgs {
        inherit system;
        nixpkgs = inputs.nixpkgs-stable;
      };

      zen-browser = mkIf (elem system ["aarch64-linux" "x86_64-linux"]) inputs.zen-browser.packages.${system}.default;
      zen-browser-twilight = mkIf (elem system ["aarch64-linux" "x86_64-linux"]) inputs.zen-browser.packages.${system}.twilight;
    };

    # Overlays from inputs
    nixgl = inputs.nixgl.overlay;
  };

  mkPkgs = {
    nixpkgs,
    overlays ? [],
    system,
  }:
    import nixpkgs {
      inherit overlays system;
      config.allowUnfree = true;
    };

  pkgsFor = system:
    mkPkgs {
      inherit system;
      inherit (inputs) nixpkgs;
      overlays = attrValues inputs.self.overlays;
    };
in {
  flake = {
    inherit pkgsFor overlays;
  };
  perSystem = {system, ...}: {
    _module.args = {
      pkgs = pkgsFor system;
    };
  };
}
