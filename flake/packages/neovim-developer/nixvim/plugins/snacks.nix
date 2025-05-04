{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [
    ./snacks/picker.nix
  ];
  plugins = {
    snacks = {
      enable = true;
      package = pkgs.vimPlugins.snacks-nvim-git;
      settings = {
        animate = {
          enabled = true;
          duration = 20; # ms per step
          easing = "linear";
          fps = 60;
        };
        bigfile = {
          enabled = true;
          notify = true;
          size = 50 * 1024; # ~ 50 KB
        };
        bufdelete = {
          enabled = true;
        };
        dashboard = {
          enabled = true;
        };
        debug = {
          enabled = true;
        };
        git = {
          enabled = true;
        };
        gitbrowse = {
          enabled = true;
        };
        indent = {
          enabled = with config.plugins; !mini.enable || !(hasAttr "indentscope" mini.modules);
          priority = 1;
          char.__raw =
            # lua
            ''
              _M.custom.icons.ui.SeparatorDashed
            '';
          only_current = true;
          only_scope = false;
          hl = [
            "SnacksIndent1"
            "SnacksIndent2"
            "SnacksIndent3"
            "SnacksIndent4"
            "SnacksIndent5"
            "SnacksIndent6"
            "SnacksIndent7"
            "SnacksIndent8"
          ];
        };
        input = {
          enabled = true;
        };
        notifier = {
          enabled = true;
          timeout = 3000;
        };
        picker = {
          enabled = true;
        };
        quickfile = {
          enabled = true;
        };
        scope = {
          enabled = true;
        };
        scroll = {
          enabled = true;
        };
        statuscolumn = {
          enabled = false;
        };
        # terminal = {
        #   # adapted from https://www.reddit.com/r/neovim/comments/1gv4z6k/comment/ly2jpif/
        #   enabled = true;
        #   cmd.__raw = "vim.env.SHELL";
        #   env = {
        #     TERM = "xterm-256color";
        #   };
        #   win = {
        #     style = "terminal";
        #     relative = "editor";
        #     width = 0.83;
        #     height = 0.83;
        #   };
        # };
        toggle = {
          enabled = true;
        };
        words = {
          enabled = true;
          debounce = 100;
        };
        zen = {
          enabled = true;
          toggles = {
            dim = false;
          };
        };
      };

      luaConfig.post =
        # lua
        ''
          -- Setup some globals for debugging (lazy-loaded)
          _M.dd = function(...)
            Snacks.debug.inspect(...)
          end
          _M.bt = function()
            Snacks.debug.backtrace()
          end
          vim.print = _M.dd -- Override print to use snacks for `:=` command

          -- Create some toggle mappings
          Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.line_number():map("<leader>ul")
          Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 }):map("<leader>uc")
          Snacks.toggle.treesitter():map("<leader>uT")
          Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
          Snacks.toggle.inlay_hints():map("<leader>uh")
          Snacks.toggle.indent():map("<leader>ug")
          Snacks.toggle.dim():map("<leader>uD")
        '';
    };

    lazy.enable = attrByPath ["dashboard" "enabled"] false config.plugins.snacks.settings;
    which-key.enable = attrByPath ["toggle" "enabled"] false config.plugins.snacks.settings;
  };

  keymaps = mkMerge [
    [
      {
        mode = ["n"];
        key = "<leader>z";
        options = {desc = "Toggle Zen Mode";};
        action.__raw =
          # lua
          ''
            function() Snacks.zen() end
          '';
      }
      {
        mode = ["n"];
        key = "<leader>Z";
        options = {desc = "Toggle Zoom";};
        action.__raw =
          # lua
          ''
            function() Snacks.zen.zoom() end
          '';
      }
      {
        mode = ["n"];
        key = "<leader>.";
        options = {desc = "Toggle Scratch Buffer";};
        action.__raw =
          # lua
          ''
            function() Snacks.scratch() end
          '';
      }
      {
        mode = ["n"];
        key = "<leader>S";
        options = {desc = "Select Scratch Buffer";};
        action.__raw =
          # lua
          ''
            function() Snacks.scratch.select() end
          '';
      }
      {
        mode = ["n"];
        key = "<leader>n";
        options = {desc = "Notification History";};
        action.__raw =
          # lua
          ''
            function() Snacks.notifier.show_history() end
          '';
      }
      {
        mode = ["n"];
        key = "<leader>bd";
        options = {desc = "Delete Buffer";};
        action.__raw =
          # lua
          ''
            function() Snacks.bufdelete() end
          '';
      }
      {
        mode = ["n"];
        key = "<leader>cR";
        options = {desc = "Rename File";};
        action.__raw =
          # lua
          ''
            function() Snacks.rename.rename_file() end
          '';
      }
      {
        mode = ["n" "v"];
        key = "<leader>gB";
        options = {desc = "Git Browse";};
        action.__raw =
          # lua
          ''
            function() Snacks.gitbrowse() end
          '';
      }
      {
        mode = ["n"];
        key = "<leader>gb";
        options = {desc = "Git Blame Line";};
        action.__raw =
          # lua
          ''
            function() Snacks.git.blame_line() end
          '';
      }
      {
        mode = ["n"];
        key = "<leader>un";
        options = {desc = "Dismiss All Notifications";};
        action.__raw =
          # lua
          ''
            function() Snacks.notifier.hide() end
          '';
      }
      {
        mode = ["n" "t"];
        key = "<C-/>";
        options = {
          desc = "Toggle Centered Terminal";
          # silent = true;
        };
        action.__raw =
          # lua
          ''
            -- adapted from https://www.reddit.com/r/neovim/comments/1gv4z6k/comment/ly2jpif/
            function()
              -- Check if we're in terminal mode
              if vim.bo.buftype == "terminal" then
                vim.cmd("hide") -- Hide the terminal if we're in terminal mode
              else
                -- Show/create terminal if we're in normal mode
                Snacks.terminal.toggle(vim.env.SHELL, {
                  env = {
                    TERM = "xterm-256color",
                  },
                  win = {
                    position = "float";
                    style = "terminal",
                    relative = "editor",
                    width = 0.83,
                    height = 0.83,
                  },
                })
              end
            end
          '';
      }
      {
        mode = ["n" "t"];
        key = "]]";
        options = {desc = "Next Reference";};
        action.__raw =
          # lua
          ''
            function() Snacks.words.jump(vim.v.count1) end
          '';
      }
      {
        mode = ["n" "t"];
        key = "[[";
        action.__raw =
          # lua
          ''function() Snacks.words.jump(-vim.v.count1) end'';
        options = {desc = "Prev Reference";};
      }
      {
        mode = ["n"];
        key = "<leader>N";
        options = {desc = "Neovim News";};
        action.__raw =
          # lua
          ''
            function()
              Snacks.win({
                file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
                width = 0.6,
                height = 0.6,
                wo = {
                  conceallevel = 3,
                  signcolumn = "yes",
                  spell = false,
                  statuscolumn = " ",
                  wrap = false,
                },
              })
            end
          '';
      }
    ]

    (
      mkIf config.plugins.lazygit.enable
      [
        {
          mode = ["n"];
          key = "<leader>gf";
          options = {desc = "Lazygit Current File History";};
          action.__raw =
            # lua
            ''
              function() Snacks.lazygit.log_file() end
            '';
        }
        {
          mode = ["n"];
          key = "<leader>gg";
          options = {desc = "Lazygit";};
          action.__raw =
            # lua
            ''
              function() Snacks.lazygit() end
            '';
        }
        {
          mode = ["n"];
          key = "<leader>gl";
          options = {desc = "Lazygit Log (cwd)";};
          action.__raw =
            # lua
            ''
              function() Snacks.lazygit.log() end
            '';
        }
      ]
    )
  ];
}
