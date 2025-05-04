{inputs, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: {
    packages = {
      default = config.packages.neovim-developer;
      neovim-developer = import ./packages/neovim-developer.nix {
        inherit (inputs) nixvim;
        inherit pkgs;
      };
    };
  };
}
