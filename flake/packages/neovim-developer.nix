{
  nixvim,
  pkgs,
  ...
}:
nixvim.legacyPackages.${pkgs.system}.makeNixvimWithModule {
  inherit pkgs;
  module = ./neovim-developer/nixvim;
}
# {
#   nixvim,
#   pkgs,
#   ...
# }:
# (nixvim.legacyPackages.${pkgs.system}.makeNixvimWithModule {
#   inherit pkgs;
#   module = ./neovim-developer/nixvim;
# }).overrideAttrs (previous: {
#   meta =
#     previous.meta or {}
#     // {
#       description = "Developer-oriented Neovim with nixvim configuration";
#       license = pkgs.lib.licenses.mit;
#       platforms = pkgs.lib.platforms.all;
#       teams = [];
#     };
# })

