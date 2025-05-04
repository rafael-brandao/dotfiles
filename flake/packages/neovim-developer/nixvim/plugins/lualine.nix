# TODO: port configuration from
# https://github.com/benfrain/neovim/blob/main/lua/setup/lualine.lua
#
{
  plugins.lualine = {
    enable = true;
    settings = {
      options = {
        disabled_filetypes = {
          __unkeyed-1 = "netrw";
          __unkeyed-2 = "snacks_dashboard";
        };
        globalstatus = true;
      };
    };
  };

  opts = {
    showmode = false; # Disable neovim showmode when using lualine
  };

  keymaps = [
    {
      mode = "n";
      key = "n";
      action.__raw =
        # lua
        ''
          function()
            vim.cmd("silent normal! nzzzv")
            require("lualine").refresh()
          end
        '';
      options = {
        desc = "Search forward and center the view";
      };
    }
    {
      mode = "n";
      key = "N";
      action.__raw =
        # lua
        ''
          function()
            vim.cmd("silent normal! Nzzzv")
            require("lualine").refresh()
          end
        '';
      options = {
        desc = "Search backward and center the view";
      };
    }
  ];
}
