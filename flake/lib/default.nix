{inputs, ...} @ flakeArgs: let
  nix-contrib = import inputs.nix-contrib {lib-nixpkgs = inputs.nixpkgs.lib;};
  extended-lib = (import ./local) {
    inherit flakeArgs;
    inherit (nix-contrib) lib;
  };
in {
  flake = {
    lib = extended-lib;
  };
}
