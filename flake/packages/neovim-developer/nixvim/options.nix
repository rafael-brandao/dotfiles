{lib, ...}:
with lib; {
  # clipboard.register = "unnamedplus"; #        Use the system clipboard

  globals = {
    mapleader = ",";
    maplocalleader = ",";
  };

  opts = {
    autoindent = true; #                        Copy indent from current line when starting new one
    breakindent = true; #                       Enable break indentation
    completeopt = "menuone,noselect"; #         Set completeopt to have a better completion experience
    expandtab = true; #                         Use spaces instead of tabs
    foldmethod = "manual"; #                    Set manual folding
    hlsearch = true; #                          Highlight search matches
    ignorecase = true; #                        Ignore case when searching
    inccommand = "split"; #                     Show substitutions as they are typed
    incsearch = true; #                         Incremental search
    linebreak = true; #                         Wrap lines at word boundaries
    modeline = true; #                          Enable the use of modelines in files. Modelines allow you to set file-specific editor options.
    modelines = 5; #                            Number of lines at the beginning and end of a file to scan for modelines.
    more = false; #                             Disable the "Press ENTER" prompt for more output
    mouse = ""; #                               Disable mouse mode
    number = true; #                            Show line numbers
    relativenumber = true; #                    Show relative line numbers
    scrolloff = 10; #                           Minimum number of lines to keep above and below the cursor
    shada = ["'10" "<0" "s10" "h"]; #           Configure session history options
    shiftwidth = 2; #                           Number of spaces per indentation level
    signcolumn = "yes"; #                       Always show the sign column
    smartcase = true; #                         Smart case-sensitive search
    softtabstop = 2; #                          Number of spaces for Tab key or auto-indent
    splitbelow = true; #                        Open splits below the current window
    splitright = true; #                        Open splits to the right of the current window
    swapfile = false; #                         Disable swapfile creation
    tabstop = 2; #                              Number of spaces that a tab character represents
    termguicolors = true; #                     Enable true color support
    wrap = true; #                              Enable line wrapping
    undofile = true; #                          Save undo history

    # updatetime = 250;  #                        (Disabled) Decrease time before writing swap file
    # timeoutlen = 200;  #                        (Disabled) Decrease timeout length for key sequences
  };

  extraConfigLuaPre =
    mkOrder 600
    # lua
    ''
      -- Set up options from lua code {{{
      vim.opt.formatoptions:remove "o" --     Do not insert a new comment when pressing 'o'
      vim.opt.iskeyword:append("-") --        Treat hyphenated words as a single word, like with underscores
      -- vim.opt.isfname:append("@-@") --        Treat hyphenated words as a single word, like with underscores
      -- }}}
    '';
}
