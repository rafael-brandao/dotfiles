{config, ...}: {
  plugins.otter = {
    inherit (config.plugins.treesitter) enable;
  };
}
