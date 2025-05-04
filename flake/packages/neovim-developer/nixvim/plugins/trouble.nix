{
  config,
  pkgs,
  ...
}: {
  plugins.trouble = {
    inherit (config.plugins.lsp) enable;
    package = pkgs.vimPlugins.trouble-nvim-git;
  };
}
