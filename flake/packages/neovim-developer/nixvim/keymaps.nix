# https://github.com/2KAbhishek/nvim2k/blob/main/lua/core/keys.lua
# https://github.com/josean-dev/dev-environment-files/blob/main/.config/nvim/lua/josean/core/keymaps.lua
# https://github.com/omerxx/dotfiles/blob/master/nvim/lua/keymaps.lua
# https://github.com/ThePrimeagen/init.lua/blob/master/lua/theprimeagen/remap.lua
# https://github.com/benfrain/neovim/blob/main/lua/mappings.lua
#
#
# TODO: @keymaps@ standardize keymaps and comments to match TJ Devries ones
{
  config,
  lib,
  ...
}: let
  mkDefaultOpts = let
    defaultOpts = {
      noremap = true;
      silent = true;
    };
  in
    opts: defaultOpts // opts;
in
  with lib; {
    keymaps = mkMerge [
      [
        {
          mode = "i";
          key = "jj";
          action = "<Esc>";
          options = mkDefaultOpts {
            desc = "Escape shortcut";
            noremap = false;
          };
        }
        {
          mode = "n";
          key = "<leader>ee";
          action = "<cmd>Ex<CR>";
          options = mkDefaultOpts {
            desc = "Open netrw file manager";
          };
        }
        {
          mode = "n";
          key = "J";
          action = "mzJ`z";
          options = mkDefaultOpts {
            desc = "Join lines while keeping cursor position";
          };
        }
        {
          mode = "n";
          key = "<C-d>";
          action = "<C-d>zz";
          options = {
            desc = "Scroll down and center the view";
          };
        }
        {
          mode = "n";
          key = "<C-u>";
          action = "<C-u>zz";
          options = {
            desc = "Scroll up and center the view";
          };
        }
        {
          mode = "x";
          key = "<leader>p";
          action.__raw = ''[["_dP]]'';
          options = mkDefaultOpts {
            desc = "Paste preserving the register content";
          };
        }
        {
          mode = "x";
          key = "<leader>cp";
          action.__raw = ''[["_d"+P]]'';
          options = mkDefaultOpts {
            desc = "Paste from the system clipboard preserving the register content";
          };
        }
        {
          mode = "n";
          key = "<leader>cp";
          action.__raw = ''[["+p]]'';
          options = mkDefaultOpts {
            desc = "Paste from the system clipboard";
          };
        }
        {
          mode = ["n" "v"];
          key = "<leader>y";
          action.__raw = ''[["+y]]'';
          options = mkDefaultOpts {
            desc = "Yank to the system clipboard";
          };
        }
        {
          mode = "n";
          key = "<leader>Y";
          action.__raw = ''[["+Y]]'';
          options = mkDefaultOpts {
            desc = "Yank the entire line to the system clipboard";
          };
        }
        {
          mode = ["n" "v"];
          key = "<leader>d";
          action.__raw = ''[["_d]]'';
          options = mkDefaultOpts {
            desc = "Delete to void register without modifying the current register content";
          };
        }
        # {
        #   mode = "n";
        #   key = "<leader>f";
        #   action = "vim.lsp.buf.format";
        #   options = mkDefaultOpts {
        #     desc = "Format the current buffer using LSP";
        #   };
        # }
        {
          mode = "n";
          key = "<leader>qq";
          options = {
            desc = "Quit without saving";
            noremap = false;
          };
          action = ":q!<CR>";
        }
        {
          mode = "n";
          key = "<leader>ww";
          options = {
            desc = "Save the current buffer";
            noremap = false;
          };
          action = ":w!<CR>";
        }
        {
          mode = "n";
          key = "<leader>wq";
          options = {
            desc = "Save the current buffer and quit";
            noremap = false;
          };
          action = ":wq<CR>";
        }
        {
          mode = "n";
          key = "<leader>wa";
          options = {
            desc = "Save all open buffers";
            noremap = false;
          };
          action = ":wa<CR>";
        }
        {
          mode = "n";
          key = "E";
          options = {
            desc = "Move to the end of the line";
            noremap = false;
          };
          action = "$";
        }
        {
          mode = "n";
          key = "B";
          options = {
            desc = "Move to the beginning of the line";
            noremap = false;
          };
          action = "^";
        }
        {
          mode = "n";
          key = "<C-k>";
          action = "<cmd>cnext<CR>zz";
          options = mkDefaultOpts {
            desc = "Jump to the next item in the quickfix list and center the view";
          };
        }
        {
          mode = "n";
          key = "<C-j>";
          action = "<cmd>cprev<CR>zz";
          options = mkDefaultOpts {
            desc = "Jump to the previous item in the quickfix list and center the view";
          };
        }
        {
          mode = "n";
          key = "<leader>k";
          action = "<cmd>lnext<CR>zz";
          options = mkDefaultOpts {
            desc = "Jump to the next item in the location list and center the view";
          };
        }
        {
          mode = "n";
          key = "<leader>j";
          action = "<cmd>lprev<CR>zz";
          options = mkDefaultOpts {
            desc = "Jump to the previous item in the location list and center the view";
          };
        }
        # {
        #   mode = "n";
        #   key = "<leader>s";
        #   action.__raw = "[[:%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>]]";
        #   options = {
        #     desc = "Search and replace the word under the cursor globally with confirmation";
        #     noremap = true;
        #   };
        # }
        {
          mode = "n";
          key = "<C-j>";
          action = "<C-w><C-j>";
          options = mkDefaultOpts {
            desc = "Move to the split below";
          };
        }
        {
          mode = "n";
          key = "<C-k>";
          action = "<C-w><C-k>";
          options = mkDefaultOpts {
            desc = "Move to the split above";
          };
        }
        {
          mode = "n";
          key = "<C-l>";
          action = "<C-w><C-l>";
          options = mkDefaultOpts {
            desc = "Move to the split on the right";
          };
        }
        {
          mode = "n";
          key = "<C-h>";
          action = "<C-w><C-h>";
          options = mkDefaultOpts {
            desc = "Move to the split on the left";
          };
        }
        {
          mode = "n";
          key = "<M-,>";
          action = "<C-w>5<";
          options = mkDefaultOpts {
            desc = "Decrease window width";
          };
        }
        {
          mode = "n";
          key = "<M-.>";
          action = "<C-w>5>";
          options = mkDefaultOpts {
            desc = "Increase window width";
          };
        }
        {
          mode = "n";
          key = "<M-t>";
          action = "<C-w>+";
          options = mkDefaultOpts {
            desc = "Increase window height";
          };
        }
        {
          mode = "n";
          key = "<M-s>";
          action = "<C-w>-";
          options = mkDefaultOpts {
            desc = "Decrease window height";
          };
        }
        {
          mode = "n";
          key = "<leader>x";
          action = "<cmd>.lua<CR>";
          options = mkDefaultOpts {
            desc = "Execute the current line";
          };
        }
        {
          mode = "n";
          key = "<leader><leader>x";
          action = "<cmd>source %<CR>";
          options = mkDefaultOpts {
            desc = "Execute the current file";
          };
        }
        # { TODO: better key mapping for changing to the previous tab
        #   mode = "n";
        #   key = "<left>";
        #   action = "gT";
        #   options = { desc = "Switch to the previous tab"; noremap = true; silent = true; };
        # }
        # { TODO: better key mapping for changing to the next tab
        #   mode = "n";
        #   key = "<right>";
        #   action = "gt";
        #   options = { desc = "Switch to the next tab"; noremap = true; silent = true; };
        # }
        {
          key = "Ç";
          action = ":";
          options = {
            desc = "Switch to command mode using ABNT2 keyboard";
            noremap = true;
          };
        }
        {
          mode = "n";
          key = "]d";
          options = mkDefaultOpts {
            desc = "Jump to next diagnostic (with float)";
          };
          action.__raw =
            # lua
            ''
              _M.fn(vim.diagnostic.jump, { count = 1, float = true })
            '';
        }
        {
          mode = "n";
          key = "[d";
          options = mkDefaultOpts {
            desc = "Jump to previous diagnostic (with float)";
          };
          action.__raw =
            # lua
            ''
              _M.fn(vim.diagnostic.jump, { count = -1, float = true })
            '';
        }
        {
          mode = ["n" "i"];
          key = "<C-z>";
          options = {
            desc = "Remap Ctrl-Z to Nop if running on WSL"; # NOTE: Windows Terminal wrongfuly interprets some key combinations as Ctrl+z
            expr = true;
          };
          action.__raw =
            # lua
            ''
              function()
                if vim.fn.has("wsl") == 1 then
                  return ""
                else
                  return vim.keycode "<C-z>"
                end
              end
            '';
        }
        {
          mode = "n";
          key = "<CR>";
          options = {
            desc = "Toggle hlsearch if it's on, otherwise just do 'enter'";
            expr = true;
          };
          action.__raw =
            # lua
            ''
              function()
                if vim.v.hlsearch == 1 then
                  vim.cmd.nohl()
                  return ""
                else
                  return vim.keycode "<CR>"
                end
              end
            '';
        }
        {
          mode = "n";
          key = "<M-j>";
          options = mkDefaultOpts {
            desc = "Move the current line down (diff mode: change)";
          };
          action.__raw =
            # lua
            ''
              function()
                if vim.opt.diff:get() then
                  vim.cmd [[normal! ]c]]
                else
                  vim.cmd [[m .+1<CR>==]]
                end
              end
            '';
        }
        {
          mode = "n";
          key = "<M-k>";
          options = mkDefaultOpts {
            desc = "Move the current line up (diff mode: change)";
          };
          action.__raw =
            # lua
            ''
              function()
                if vim.opt.diff:get() then
                  vim.cmd [[normal! [c]]
                else
                  vim.cmd [[m .-2<CR>==]]
                end
              end
            '';
        }
        {
          mode = "v";
          key = "<M-j>";
          options = mkDefaultOpts {
            desc = "Move selected lines down, keeping the indentation";
          };
          action = ":m '>+1<CR>gv=gv";
        }
        {
          mode = "v";
          key = "<M-k>";
          options = mkDefaultOpts {
            desc = "Move selected lines up, keeping the indentation";
          };
          action = ":m '<-2<CR>gv=gv";
        }
        {
          mode = "n";
          key = "<space>tt";
          options = mkDefaultOpts {
            desc = "Toggle LSP inlay hints";
          };
          action.__raw =
            # lua
            ''
              function()
                vim.lsp.inlay_hint.enable(
                  not vim.lsp.inlay_hint.is_enabled { bufnr = 0 }, { bufnr = 0 }
                )
              end
            '';
        }
        {
          mode = "n";
          key = "<leader>t";
          action = "<Plug>PlenaryTestFile";
          options = {
            desc = "Run tests for the current file";
            noremap = false;
            silent = false;
          };
        }
        {
          mode = "n";
          key = "j";
          action = "v:count == 0 ? 'gj' : 'j'";
          options = {
            desc = "Better down movement, considering wrapped lines";
            expr = true;
            silent = true;
          };
        }
        {
          mode = "n";
          key = "k";
          action = "v:count == 0 ? 'gk' : 'k'";
          options = {
            desc = "Better up movement, considering wrapped lines";
            expr = true;
            silent = true;
          };
        }
      ]
      (
        mkIf (!config.plugins.lualine.enable)
        [
          {
            mode = "n";
            key = "n";
            action = "nzzzv";
            options = mkDefaultOpts {
              desc = "Search forward and center the view";
            };
          }
          {
            mode = "n";
            key = "N";
            action = "Nzzzv";
            options = mkDefaultOpts {
              desc = "Search backward and center the view";
            };
          }
        ]
      )
    ];
  }
