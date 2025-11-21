{
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [
    ./extra-files
    ./extra-lua.nix
    ./keymaps.nix
    ./options.nix
    ./plugins.nix
  ];

  package = mkDefault pkgs.neovim-nightly;

  extraPackages = with pkgs; [
    gcc
    nodejs
  ];

  extraLuaPackages = luaPkgs:
    with luaPkgs; [
      sqlite
    ];

  colorschemes = {
    catppuccin = {
      enable = mkOverride 1050 true;
      settings = {
        flavour = mkOverride 1050 "mocha";
      };
    };
  };

  filetype = {
    extension = {
      # h = "c";
    };
    filename = {
      "flake.lock" = "json";
      ".yamlfmt" = "yaml";
      ".yamllint" = "yaml";
    };
  };

  autoGroups = {
    auto-create-dir = {clear = true;};
    last-loc = {clear = true;};
    resize-splits = {clear = true;};
    yank-highlight = {clear = true;};
  };

  autoCmd = [
    # auto create dir when saving a file, in case some intermediate directory does not exist
    {
      event = "BufReadPre";
      group = "auto-create-dir";
      callback.__raw =
        # lua
        ''
          function(event)
            local file = vim.loop.fs_realpath(event.match) or event.match
            vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
          end
        '';
    }

    # go to last loc when opening a buffer
    {
      event = "BufReadPost";
      group = "last-loc";
      callback.__raw =
        # lua
        ''
          function()
            local mark = vim.api.nvim_buf_get_mark(0, '"')
            local lcount = vim.api.nvim_buf_line_count(0)
            if mark[1] > 0 and mark[1] <= lcount then
              pcall(vim.api.nvim_win_set_cursor, 0, mark)
            end
          end
        '';
    }

    # resize splits if window got resized
    {
      event = "VimResized";
      group = "resize-splits";
      callback.__raw =
        # lua
        ''
          function()
            vim.cmd('tabdo wincmd =')
          end
        '';
    }

    # highlight on yank
    {
      event = "TextYankPost";
      group = "yank-highlight";
      pattern = "*";
      callback.__raw =
        # lua
        ''
          function()
            vim.highlight.on_yank()
          end
        '';
    }
  ];
}
