{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
  mkIf (!config.plugins.snacks.settings.picker.enabled) {
    extraConfigLuaPre =
      mkOrder 1210
      # lua
      ''
        -- Telescope
        _M.telescope = { };
        _M.telescope.builtin = require "telescope.builtin"
      '';

    plugins.telescope = {
      enable = true;
      settings = {
        defaults = {
          file_ignore_patterns = [
            "%.ipynb"
            "^.direnv/"
            "^.git/"
            "^.mypy_cache/"
            "^__pycache__/"
            "^data/"
            "^output/"
            "dune.lock"
          ];
        };
        extensions = {
          wrap_results = true;
          history = {
            limit = 100;
            path.__raw =
              # lua
              ''
                vim.fs.joinpath(_M.data, "telescope_history.sqlite3")
              '';
          };

          "ui-select".__raw =
            # lua
            ''
              {
                require("telescope.themes").get_dropdown {},
              }
            '';
        };
      };

      keymaps = {
        "<space>/".action = "current_buffer_fuzzy_find";
        "<space>fb".action = "buffers";
        "<space>fd".action = "find_files";
        "<space>fh".action = "help_tags";
        "<space>gw".action = "grep_string";
      };

      extensions = {
        fzy-native.enable = true;
        ui-select.enable = true;
      };

      enabledExtensions = [
        "smart_history"
      ];
    };

    extraPlugins = with pkgs.vimPlugins; [
      telescope-smart-history-nvim
    ];

    keymaps = [
      {
        mode = "n";
        key = "<space>ft";
        action.__raw =
          # lua
          ''
            function()
              _M.telescope.builtin.git_files { cwd = vim.fn.expand "%:h" }
            end
          '';
      }
      {
        mode = "n";
        key = "<space>fg";
        action.__raw =
          # lua
          ''
            require "custom.telescope.multi-ripgrep"
          '';
      }
      {
        mode = "n";
        key = "<space>en";
        action.__raw =
          # lua
          ''
            function()
              _M.telescope.builtin.find_files { cwd = vim.fn.stdpath "config" }
            end
          '';
      }
    ];
  }
