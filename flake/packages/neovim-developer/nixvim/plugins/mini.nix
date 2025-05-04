{
  plugins.mini = {
    enable = true;
    mockDevIcons = true;
    modules = {
      icons = {};
      indentscope = {};
    };
  };

  autoGroups = {
    mini-disable-identscope = {clear = true;};
  };

  autoCmd = [
    # disable MiniIdentscope on certain patterns
    {
      event = ["Filetype"];
      group = "mini-disable-identscope";
      pattern = [
        "snacks_dashboard"
        "snacks_terminal"
        "trouble"
      ];
      callback.__raw =
        # lua
        ''
          function(args)
            vim.b[args.buf].miniidentscope_disable = true
          end
        '';
    }
  ];
}
