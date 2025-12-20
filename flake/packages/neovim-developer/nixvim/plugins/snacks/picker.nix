{
  config,
  lib,
  ...
}:
with lib;
  mkMerge [
    {
      plugins = {
        snacks.settings.picker = {
          enabled = true;
          formatters.file.filename_first = true;
          matcher.cwd_bonus = true;
          win.input.keys = {
            "<C-y>".__raw =
              # lua
              ''
                { "confirm", mode = { "n", "i" }, }
              '';
          };
        };
      };
      keymaps = [
        # Snacks picker mappings
        {
          mode = ["n"];
          key = "<leader>,";
          options = {desc = "Buffers";};
          action.__raw = "function() Snacks.picker.buffers() end";
        }
        {
          mode = ["n"];
          key = "<leader>/";
          options = {desc = "Grep";};
          action.__raw = "function() Snacks.picker.grep() end";
        }
        {
          mode = ["n"];
          key = "<leader>:";
          options = {desc = "Command History";};
          action.__raw = "function() Snacks.picker.command_history() end";
        }
        {
          mode = ["n"];
          key = "<leader><space>";
          options = {desc = "Find Files";};
          action.__raw = "function() Snacks.picker.files() end";
        }

        # Find
        {
          mode = ["n"];
          key = "<leader>fb";
          options = {desc = "Buffers";};
          action.__raw = "function() Snacks.picker.buffers() end";
        }
        {
          mode = ["n"];
          key = "<leader>fc";
          options = {desc = "Find Config File";};
          action.__raw = "function() Snacks.picker.files({ cwd = vim.fn.stdpath('config') }) end";
        }
        # {
        #   mode = ["n"];
        #   key = "<leader>ff";
        #   options = {desc = "Find Files";};
        #   action.__raw = "function() Snacks.picker.files() end";
        # }
        {
          mode = ["n"];
          key = "<leader>fg";
          options = {desc = "Find Git Files";};
          action.__raw = "function() Snacks.picker.git_files() end";
        }
        {
          mode = ["n"];
          key = "<leader>fr";
          options = {desc = "Recent Files Within CWD";};
          action.__raw = "function() Snacks.picker.recent( {filter = {cwd = true} }) end";
        }
        {
          mode = ["n"];
          key = "<leader>fR";
          options = {desc = "Recent Files";};
          action.__raw = "function() Snacks.picker.recent() end";
        }

        # Git
        {
          mode = ["n"];
          key = "<leader>gc";
          options = {desc = "Git Log";};
          action.__raw = "function() Snacks.picker.git_log() end";
        }
        {
          mode = ["n"];
          key = "<leader>gs";
          options = {desc = "Git Status";};
          action.__raw = "function() Snacks.picker.git_status() end";
        }

        # Grep
        {
          mode = ["n"];
          key = "<leader>sb";
          options = {desc = "Buffer Lines";};
          action.__raw = "function() Snacks.picker.lines() end";
        }
        {
          mode = ["n"];
          key = "<leader>sB";
          options = {desc = "Grep Open Buffers";};
          action.__raw = "function() Snacks.picker.grep_buffers() end";
        }
        {
          mode = ["n"];
          key = "<leader>sg";
          options = {desc = "Grep";};
          action.__raw = "function() Snacks.picker.grep() end";
        }
        {
          mode = ["n" "x"];
          key = "<leader>sw";
          options = {desc = "Visual selection or word";};
          action.__raw = "function() Snacks.picker.grep_word() end";
        }

        # Search
        {
          mode = ["n"];
          key = "<leader>s\"";
          options = {desc = "Registers";};
          action.__raw = "function() Snacks.picker.registers() end";
        }
        {
          mode = ["n"];
          key = "<leader>sa";
          options = {desc = "Autocmds";};
          action.__raw = "function() Snacks.picker.autocmds() end";
        }
        {
          mode = ["n"];
          key = "<leader>sc";
          options = {desc = "Command History";};
          action.__raw = "function() Snacks.picker.command_history() end";
        }
        {
          mode = ["n"];
          key = "<leader>sC";
          options = {desc = "Commands";};
          action.__raw = "function() Snacks.picker.commands() end";
        }
        {
          mode = ["n"];
          key = "<leader>sd";
          options = {desc = "Diagnostics";};
          action.__raw = "function() Snacks.picker.diagnostics() end";
        }
        {
          mode = ["n"];
          key = "<leader>sh";
          options = {desc = "Help Pages";};
          action.__raw = "function() Snacks.picker.help() end";
        }
        {
          mode = ["n"];
          key = "<leader>sH";
          options = {desc = "Highlights";};
          action.__raw = "function() Snacks.picker.highlights() end";
        }
        {
          mode = ["n"];
          key = "<leader>sj";
          options = {desc = "Jumps";};
          action.__raw = "function() Snacks.picker.jumps() end";
        }
        {
          mode = ["n"];
          key = "<leader>sk";
          options = {desc = "Keymaps";};
          action.__raw = "function() Snacks.picker.keymaps() end";
        }
        {
          mode = ["n"];
          key = "<leader>sl";
          options = {desc = "Location List";};
          action.__raw = "function() Snacks.picker.loclist() end";
        }
        {
          mode = ["n"];
          key = "<leader>sM";
          options = {desc = "Man Pages";};
          action.__raw = "function() Snacks.picker.man() end";
        }
        {
          mode = ["n"];
          key = "<leader>sm";
          options = {desc = "Marks";};
          action.__raw = "function() Snacks.picker.marks() end";
        }
        {
          mode = ["n"];
          key = "<leader>sR";
          options = {desc = "Resume";};
          action.__raw = "function() Snacks.picker.resume() end";
        }
        {
          mode = ["n"];
          key = "<leader>sq";
          options = {desc = "Quickfix List";};
          action.__raw = "function() Snacks.picker.qflist() end";
        }
        {
          mode = ["n"];
          key = "<leader>uC";
          options = {desc = "Colorschemes";};
          action.__raw = "function() Snacks.picker.colorschemes() end";
        }
        {
          mode = ["n"];
          key = "<leader>qp";
          options = {desc = "Projects";};
          action.__raw = "function() Snacks.picker.projects() end";
        }

        # LSP
        {
          mode = ["n"];
          key = "gd";
          options = {desc = "Goto Definition";};
          action.__raw = "function() Snacks.picker.lsp_definitions() end";
        }
        {
          mode = ["n"];
          key = "gr";
          options = {
            desc = "References";
            nowait = true;
          };
          action.__raw = "function() Snacks.picker.lsp_references() end";
        }
        {
          mode = ["n"];
          key = "gI";
          options = {desc = "Goto Implementation";};
          action.__raw = "function() Snacks.picker.lsp_implementations() end";
        }
        {
          mode = ["n"];
          key = "gy";
          options = {desc = "Goto T[y]pe Definition";};
          action.__raw = "function() Snacks.picker.lsp_type_definitions() end";
        }
        {
          mode = ["n"];
          key = "<leader>ss";
          options = {desc = "LSP Symbols";};
          action.__raw = "function() Snacks.picker.lsp_symbols() end";
        }
      ];
    }
    (mkIf config.plugins.todo-comments.enable {
      keymaps = [
        {
          mode = ["n"];
          key = "<leader>st";
          options = {desc = "Todo";};
          action.__raw =
            # lua
            ''
              function() Snacks.picker.todo_comments() end
            '';
        }
        {
          mode = ["n"];
          key = "<leader>sT";
          options = {desc = "Todo/Fix/Fixme";};
          action.__raw =
            # lua
            ''
              function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end
            '';
        }
      ];
    })
    (mkIf config.plugins.trouble.enable {
      plugins.snacks.settings = {
        actions.__raw =
          # lua
          ''
            require('trouble.sources.snacks').actions
          '';
        win.input.keys = {
          "<C-t>".__raw =
            # lua
            ''
              { "trouble_open", mode = { "n", "i" }, }
            '';
        };
      };
    })
  ]
