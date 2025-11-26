{lib, ...}:
with lib; let
  plugins = let
    list = [
      "blink-cmp"
      "colorizer"
      "gitsigns"
      "lazygit"
      "lsp"
      "mini"
      # "mini-animate"
      "otter"
      "render-markdown"
      "snacks"
      "statusline"
      "telescope" # telescoped will be enabled only when snacks picker is not enabled
      "todo-comments"
      "transparent"
      "treesitter"
      "trouble"
      "tiny-inline-diagnostic"
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
