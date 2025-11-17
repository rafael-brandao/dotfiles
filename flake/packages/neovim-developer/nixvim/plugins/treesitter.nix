{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  brokenGrammars = [
    "blueprint"
    "fusion"
    "ipkg"
    "jsonc"
    "t32"
  ];
in {
  plugins = {
    treesitter = {
      enable = true;
      settings = {
        auto_install = false;
        grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars;
        ensure_installed = "all";
        ignore_install = brokenGrammars; # TODO: currently these grammars are failing to install
        # sync_install = false;
        parser_install_dir.__raw =
          # lua
          "vim.fs.joinpath(_M.data, 'treesitter')";
        indent.enable = true;
        highlight = {
          enable = true;
          additional_vim_regex_highlighting = true;
          custom_captures = {};
        };
        incremental_selection = {
          enable = true;
          keymaps = {
            init_selection = "<C-space>";
            node_incremental = "<C-space>";
            node_decremental = "<C-backspace>";
            scope_incremental = "<C-s>";
          };
        };
      };
    };

    treesitter-textobjects = {
      inherit (config.plugins.treesitter) enable;
      lspInterop.enable = true;
      select = {
        enable = true;
        includeSurroundingWhitespace = true;
        lookahead = true;
        keymaps = {
          # You can use the capture groups defined in textobjects.scm
          "a=" = {
            query = "@assignment.outer";
            desc = "Select outer part of an assignment";
          };
          "i=" = {
            query = "@assignment.inner";
            desc = "Select inner part of an assignment";
          };
          "l=" = {
            query = "@assignment.lhs";
            desc = "Select left hand side of an assignment";
          };
          "r=" = {
            query = "@assignment.rhs";
            desc = "Select right hand side of an assignment";
          };

          # works for javascript/typescript files (custom capture I created in after/queries/ecma/textobjects.scm)
          "a:" = {
            query = "@property.outer";
            desc = "Select outer part of an object property";
          };
          "i:" = {
            query = "@property.inner";
            desc = "Select inner part of an object property";
          };
          "l:" = {
            query = "@property.lhs";
            desc = "Select left part of an object property";
          };
          "r:" = {
            query = "@property.rhs";
            desc = "Select right part of an object property";
          };

          "aa" = {
            query = "@parameter.outer";
            desc = "Select outer part of a parameter/argument";
          };
          "ia" = {
            query = "@parameter.inner";
            desc = "Select inner part of a parameter/argument";
          };

          "ai" = {
            query = "@conditional.outer";
            desc = "Select outer part of a conditional";
          };
          "ii" = {
            query = "@conditional.inner";
            desc = "Select inner part of a conditional";
          };

          "al" = {
            query = "@loop.outer";
            desc = "Select inner part of a loop";
          };
          "il" = {
            query = "@loop.inner";
            desc = "Select outer part of a loop";
          };

          "am" = {
            query = "@function.outer";
            desc = "Select outer part of a method/function definition";
          };
          "im" = {
            query = "@function.inner";
            desc = "Select inner part of a method/function definition";
          };

          "ac" = {
            query = "@class.outer";
            desc = "Select outer part of a class";
          };
          "ic" = {
            query = "@class.inner";
            desc = "Select inner part of a class";
          };

          "at" = {
            query = "@comment.outer";
            desc = "Select outer part of a comment";
          };
        };
      };
      move = {
        enable = true;
        setJumps = true;
        gotoNextStart = {
          "]f" = {
            query = "@call.outer";
            desc = "Next function call start";
          };
          "]m" = {
            query = "@function.outer";
            desc = "Next method/function def start";
          };
          "]c" = {
            query = "@class.outer";
            desc = "Next class start";
          };
          "]i" = {
            query = "@conditional.outer";
            desc = "Next conditional start";
          };
          "]l" = {
            query = "@loop.outer";
            desc = "Next loop start";
          };

          # You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
          # Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
          "]s" = {
            query = "@scope";
            queryGroup = "locals";
            desc = "Next scope";
          };
          "]z" = {
            query = "@fold";
            queryGroup = "folds";
            desc = "Next fold";
          };
        };
        gotoNextEnd = {
          "]F" = {
            query = "@call.outer";
            desc = "Next function call end";
          };
          "]M" = {
            query = "@function.outer";
            desc = "Next method/function def end";
          };
          "]C" = {
            query = "@class.outer";
            desc = "Next class end";
          };
          "]I" = {
            query = "@conditional.outer";
            desc = "Next conditional end";
          };
          "]L" = {
            query = "@loop.outer";
            desc = "Next loop end";
          };
        };
        gotoPreviousStart = {
          "[f" = {
            query = "@call.outer";
            desc = "Prev function call start";
          };
          "[m" = {
            query = "@function.outer";
            desc = "Prev method/function def start";
          };
          "[c" = {
            query = "@class.outer";
            desc = "Prev class start";
          };
          "[i" = {
            query = "@conditional.outer";
            desc = "Prev conditional start";
          };
          "[l" = {
            query = "@loop.outer";
            desc = "Prev loop start";
          };
        };
        gotoPreviousEnd = {
          "[F" = {
            query = "@call.outer";
            desc = "Prev function call end";
          };
          "[M" = {
            query = "@function.outer";
            desc = "Prev method/function def end";
          };
          "[C" = {
            query = "@class.outer";
            desc = "Prev class end";
          };
          "[I" = {
            query = "@conditional.outer";
            desc = "Prev conditional end";
          };
          "[L" = {
            query = "@loop.outer";
            desc = "Prev loop end";
          };
        };
      };
      swap = {
        enable = true;
        swapNext = {
          "<leader>na" = "@parameter.inner"; # swap parameters/argument with next
          "<leader>n:" = "@property.outer"; # swap object property with next
          "<leader>nm" = "@function.outer"; # swap function with next
        };
        swapPrevious = {
          "<leader>pa" = "@parameter.inner"; # swap parameters/argument with prev
          "<leader>p:" = "@property.outer"; # swap object property with prev
          "<leader>pm" = "@function.outer"; # swap function with previous
        };
      };
    };
  };

  extraConfigLuaPre =
    mkOrder 1220
    # lua
    ''
      -- Treesitter
      _M.ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")
    '';

  keymaps =
    forEach [
      ["{" "repeat_last_move"]
      ["}" "repeat_last_move_opposite"]

      # Optionally, make builtin f, F, t, T also repeatable
      ["f" "builtin_f_expr"]
      ["F" "builtin_F_expr"]
      ["t" "builtin_t_expr"]
      ["T" "builtin_T_expr"]
    ]
    (xs: {
      mode = ["n" "x" "o"];
      key = elemAt xs 0;
      options = {expr = true;};
      action.__raw =
        # lua
        ''
          _M.ts_repeat_move.${elemAt xs 1}
        '';
    });
}
