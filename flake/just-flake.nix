{inputs, ...}: {
  imports = [inputs.just-flake.flakeModule];

  perSystem = _: {
    just-flake.features = {
      convco.enable = true;
      treefmt.enable = true;
    };
  };
}
