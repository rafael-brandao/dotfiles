{
  nixvim,
  pkgs,
  system ? pkgs.stdenv.hostPlatform.system,
  ...
}:
nixvim.legacyPackages.${system}.makeNixvimWithModule {
  inherit pkgs;
  module = [
    ./neovim-developer/nixvim
  ];
}
