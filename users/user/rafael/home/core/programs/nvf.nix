{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.programs.nvf;
in {
  programs.nvf = {
    enable = true;
    settings = {
      imports = inputs.self.modules.rb.nvf.dev;
      vim.ui.noice.enable = mkForce false;
    };
  };
  stylix.targets = {
    nvf.enable = mkDefault (!cfg.enable);
  };
}
