{pkgs, ...}: {
  plugins = {
    blink-cmp = {
      enable = true;
      package = pkgs.vimPlugins.blink-cmp-nightly;
      settings = {
        appearance = {
          nerd_font_variant = "normal";
          use_nvim_cmp_as_default = true;
        };
        completion = {
          accept = {
            auto_brackets = {
              enabled = true;
              semantic_token_resolution = {
                enabled = false;
              };
            };
          };
          documentation = {
            auto_show = true;
          };
        };
        # TODO: Remove lua implementation after fix. Error:
        #    `Luv thread: module 'blink.cmp.fuzzy.rust' not found`
        fuzzy = {
          implementation = "lua";
        };
        keymap = {
          preset = "default";
        };
        signature = {
          enabled = true;
        };
        sources = {
          cmdline = [];
          providers = {
            buffer = {
              score_offset = -7;
            };
            lsp = {
              fallbacks = [];
            };
          };
        };
      };
    };
    # lsp.capabilities =
    #   # lua
    #   ''
    #     capabilities = vim.tbl_extend("keep", capabilities or {}, require("blink-cmp").get_lsp_capabilities())
    #   '';
  };

  extraPlugins = with pkgs.vimPlugins; [
    friendly-snippets
  ];
}
