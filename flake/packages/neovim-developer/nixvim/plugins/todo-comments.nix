{pkgs, ...}: {
  plugins.todo-comments = {
    enable = true;
    package = pkgs.vimPlugins.todo-comments-nvim-git;
  };
}
