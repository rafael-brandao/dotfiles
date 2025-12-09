{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
  mkMerge [
    {
      plugins = {
        lsp = {
          enable = true;
          inlayHints = true;
          servers = {
            bashls.enable = true;
            fish_lsp.enable = true;
            lua_ls.enable = true;
            markdown_oxide.enable = true;
            nil_ls = {
              enable = true;
              package = pkgs.nil-git;
              settings = {
                formatting.command = ["alejandra"];
              };
            };
            powershell_es = {
              enable = true;
              package = pkgs.powershell-editor-services;
            };
            statix.enable = true;
            taplo.enable = true; # TOML
            yamlls.enable = true;
          };
          onAttach =
            # lua
            ''
              vim.keymap.set(
                { "n", "v" },
                "<leader>f",
                function()
                  require("conform").format({ async = true }, function(err)
                    -- Leave visual mode after range format
                    if err then
                      return
                    end
                    local mode = vim.api.nvim_get_mode().mode
                    if not vim.startswith(string.lower(mode), "v") then
                      return
                    end
                    vim.api.nvim_feedkeys(
                      vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
                      "n",
                      true
                    )
                  end)
                end,
                { buffer = bufnr, desc = "LSP: Format current buffer" }
              )
            '';
        };
        lsp-lines.enable = config.plugins.tiny-inline-diagnostic.enable;
        lsp-signature.enable = true;
        lsp-status.enable = true;
      };
    }

    {
      plugins = {
        conform-nvim = {
          inherit (config.plugins.lsp) enable;
          settings = {
            log_level = "warn";
            formatters_by_ft = rec {
              bash = [
                "shellcheck"
                "shellharden"
                "shfmt"
              ];
              json = ["jsonfmt"];
              lua = ["stylua"];
              nix = [
                # "deadnix"
                # "statix-fix"
                "alejandra"
              ];
              toml = ["toml-sort"];
              yaml = ["yamlfmt"];
              yml = yaml;
              "_" = [
                "squeeze_blanks"
                "trim_whitespace"
                "trim_newlines"
              ];
            };
            default_format_opts = {
              async = true;
              lsp_format = "fallback";
            };
            formatters = with pkgs; {
              alejandra.command = getExe alejandra;
              # deadnix.command = "${getExe deadnix}";
              jsonfmt.command = "${getExe jsonfmt}";
              shellcheck.command = getExe shellcheck;
              shellharden.command = getExe shellharden;
              shfmt.command = getExe shfmt;
              squeeze_blanks.command = getExe' coreutils "cat";
              # statix-fix.command = "${getExe statix} fix";
              stylua.command = getExe stylua;
              toml-sort.command = "${getExe toml-sort}";
              yamlfmt.command = getExe yamlfmt;
            };
          };
        };
        none-ls = {
          inherit (config.plugins.lsp) enable;
          sources = {
            code_actions = {
              statix.enable = true;
            };
            diagnostics = {
              deadnix.enable = true;
              statix.enable = true;
            };
          };
        };
      };
    }
  ]
