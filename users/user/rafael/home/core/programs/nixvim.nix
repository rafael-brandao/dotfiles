{paths, ...}: {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimdiffAlias = true;

    imports = [
      "${paths.flake.packages}/neovim-developer/nixvim"
    ];

    nixpkgs = {
      useGlobalPackages = true;
    };
  };

  stylix.targets.nixvim.enable = false;
}
#
# home = {
#   packages = with pkgs; [
#     local.neovim-developer # Nixvim as standalone package
#   ];
#   sessionPath = [
#     "${pkgs.local.neovim-developer}/bin"
#   ];
# };

