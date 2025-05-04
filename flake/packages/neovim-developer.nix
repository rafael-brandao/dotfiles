{
  nixvim,
  pkgs,
  ...
}:
nixvim.legacyPackages.${pkgs.system}.makeNixvimWithModule {
  inherit pkgs;
  module = ./neovim-developer/nixvim;
}
