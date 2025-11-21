{
  imports = [
    # ./lualine.nix
    ./mini-statusline.nix
  ];

  opts = {
    showmode = false; # Disable neovim showmode when using a statusline plugin
  };
}
