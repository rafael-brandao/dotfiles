{lib, ...}:
with lib;
  mkMerge [
    {
      extraConfigLuaPre =
        mkOrder 1100
        # lua
        ''
          -- Set up shared variables {{{
        '';
    }
    {
      extraConfigLuaPre =
        mkOrder 1101
        # lua
        ''
          _M.custom = {
            f = (require "custom.f"),
            icons =  (require "custom.icons"),
          }
          _M.fn = _M.custom.f.fn
          _M.data = assert(vim.fn.stdpath "data") --[[@as string]]
        '';
    }
    {
      extraConfigLuaPre =
        mkOrder 1300
        # lua
        ''
          -- }}}
        '';
    }
  ]
