{
  plugins.gitsigns = {
    enable = true;
    settings = {
      # See `:help gitsigns.txt`
      signs = {
        add = {text = "+";};
        change = {text = "~";};
        changedelete = {text = "~";};
        delete = {text = "_";};
        topdelete = {text = "‾";};
      };
    };
  };
}
