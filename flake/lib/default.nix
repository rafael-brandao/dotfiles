{inputs, ...} @ flakeArgs: let
  nix-contrib = import inputs.nix-contrib {lib-nixpkgs = inputs.nixpkgs.lib;};
  extended-lib = (import ./local) {
    inherit flakeArgs;
    lib = nix-contrib.lib.extend (_previous: final: final // inputs.home-manager.lib);
  };
in {
  flake = {
    lib = extended-lib;
  };
}
