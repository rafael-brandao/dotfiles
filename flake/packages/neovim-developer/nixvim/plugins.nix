{lib, ...}:
with lib; let
  plugins = let
    list = [
      "blink-cmp"
      "colorizer"
      "gitsigns"
      "lazygit"
      "lsp"
      "lualine"
      "mini"
      "otter"
      "render-markdown"
      "snacks"
      "telescope" #                enabled only if snacks picker is not enabled
      "todo-comments"
      "transparent"
      "treesitter"
      "trouble"

      # "tiny-inline-diagnostic" #  TODO: uncomment this when nixvim supports tyny-inline-diagnostics plugin natively
    ];
    filterWithPathToImport = plugin: pathExists ./plugins/${plugin}.nix;
    partitioned = partition filterWithPathToImport list;
  in {
    toImport = partitioned.right;
    toEnable = partitioned.wrong;
  };
in {
  imports = forEach plugins.toImport (plugin: ./plugins/${plugin}.nix);

  plugins = mkMerge (
    forEach plugins.toEnable (plugin: {
      ${plugin}.enable = true;
    })
  );
}
