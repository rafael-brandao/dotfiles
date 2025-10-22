{
  paths,
  pkgs,
  ...
}: {
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    vimdiffAlias = true;

    # Force nixvim to use our pkgs instance with overlays
    nixpkgs.pkgs = pkgs;

    # Import the standalone configuration to be extended
    imports = [
      "${paths.flake.packages}/neovim-developer/nixvim"
    ];

    # Override colorscheme to gruvbox
    # colorschemes = {
    #   rose-pine.enable = mkForce false;
    #   gruvbox = {
    #     enable = true;
    #   };
    # };
  };
  stylix.targets.nixvim.enable = false;
  #
  # home = {
  #   packages = with pkgs; [
  #     local.neovim-developer # Nixvim as standalone package
  #   ];
  #   sessionPath = [
  #     "${pkgs.local.neovim-developer}/bin"
  #   ];
  # };
}
