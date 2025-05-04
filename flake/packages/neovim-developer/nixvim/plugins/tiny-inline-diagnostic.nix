{
  lib,
  pkgs,
  ...
}:
with lib; {
  plugins.lazy = {
    enable = mkForce true;
    plugins = [
      {
        name = "tiny-inline-diagnostic";
        pkg = pkgs.vimPlugins.tiny-inline-diagnostic-nvim;
        # dev = true;
        event = "VeryLazy";
        priority = 1000;
        config =
          # lua
          ''
            function()
              require('tiny-inline-diagnostic').setup({})
            end
          '';
      }
    ];
  };
  # diagnostics = {
  #   virtual_text = false;
  # };
}
#
#
#
#
#
# extraPlugins = with pkgs.vimPlugins; [
#   tiny-inline-diagnostic-nvim
# ];
#
# autoGroups = {
#   tiny-inline-diagnostic-LspAttach = {clear = true;};
# };
#
# autoCmd = [
#   {
#     event = "LspAttach";
#     group = "tiny-inline-diagnostic-LspAttach";
#     callback.__raw =
#       # lua
#       ''
#         function()
#           local tid = require('tiny-inline-diagnostic')
#           tid.setup({})
#           -- Force enable after setup
#           tid.enable()
#         end
#       '';
#   }
# ];
#
# extraConfigLua =
#   mkOrder 1000
#   # lua
#   ''
#     require('tiny-inline-diagnostic').setup({})
#   '';
#
# autoGroups = {
#   tiny-inline-diagnostic-LspAttach = {clear = true;};
# };
#
# autoCmd = [
#   {
#     event = "LspAttach";
#     group = "tiny-inline-diagnostic-LspAttach";
#     callback.__raw =
#       # lua
#       ''
#         function(event)
#           local client = vim.lsp.get_client_by_id(event.data.client_id)
#           if not client then return end
#           require('tiny-inline-diagnostic').setup({})
#         end
#       '';
#   }
# ];

