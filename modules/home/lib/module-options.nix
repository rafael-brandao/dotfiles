{
  lib,
  pkgs,
  ...
}:
with lib; {
  config.lib.module-options = {
    unmount = mkOption {
      type = types.submodule ({config, ...}: {
        options = {
          fusermount = {
            binary = mkOption {
              type = types.enum ["fusermount" "fusermount3"];
              default = "fusermount3";
              description = "Fusermount command to use, either version 2 or 3.";
            };
            suid-path = mkOption {
              type = with types; listOf path;
              default = mkAfter [/run/wrappers/bin];
              description = ''
                Path from which fusermount binary will be searched for.
                The fusermount binary MUST have the suid flag set.
              '';
            };
          };
          path = mkOption {
            type = with types; listOf path;
            default =
              config.fusermount.suid-path
              ++ [
                "${pkgs.util-linux}/bin" # this provides logger, used by fusermount
              ];
            readOnly = true;
            internal = true;
            apply = flipPipe [(map toString) (mkString {sep = ":";})];
            description = "Unified paths used internally in this submodule.";
          };
        };
      });
      default = {};
      description = ''
        Unmount module with options that relates to unmounting.
      '';
    };
  };
}
