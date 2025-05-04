{inputs, ...}: {
  imports = [
    # Import home-manager's flake module
    inputs.home-manager.flakeModules.home-manager
  ];
  flake = {
    inherit
      (inputs.self.lib.local.project)
      nixosConfigurations
      homeConfigurations
      ;
  };
}
