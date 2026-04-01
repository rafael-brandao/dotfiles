{
  inputs,
  pkgs,
  ...
}: let
  modules = inputs.self.modules.rb.nvf.dev ++ [./neovim-developer/nvf];
in
  (inputs.nvf.lib.neovimConfiguration {
    inherit modules pkgs;
  }).neovim
