{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.rb.screenshot;
in {
  options.rb.screenshot = {
    enable = mkEnableOption "screenshot tool integration";

    protocol = mkOption {
      type = types.enum ["wayland" "xorg"];
      default = "wayland";
      description = "Display protocol to use for screenshot tooling.";
    };

    executableName = mkOption {
      type = types.str;
      default = "take-screenshot";
      description = "Name of the executable created for taking screenshots.";
    };

    wayland = {
      command = mkOption {
        type = types.str;
        default =
          # bash
          ''
            slurp -d -b '#2E2A1E55' -c '#FB751BFF' |
              xargs --replace={} grim -g '{}' -t ppm - |
              satty --filename -
          '';
        description = "Command to take a screenshot on Wayland.";
      };

      packages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          grim
          satty
          slurp
        ];
        defaultText = literalExpression "with pkgs; [ grim satty slurp ]";
        description = "Packages required for Wayland screenshot tooling.";
      };
    };

    xorg = {
      command = mkOption {
        type = types.str;
        default =
          # bash
          ''
            flameshot gui
          '';
        description = "Command to take a screenshot on Xorg.";
      };

      packages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          flameshot
        ];
        defaultText = literalExpression "with pkgs; [ flameshot ]";
        description = "Packages required for Xorg screenshot tooling.";
      };
    };
  };

  config = mkIf cfg.enable (let
    activeProtocol = cfg.${cfg.protocol};
    screenshotPkg = pkgs.writeShellScriptBin cfg.executableName activeProtocol.command;
  in {
    assertions = [
      {
        assertion = activeProtocol.packages != [];
        message = "rb.screenshot: packages list for protocol '${cfg.protocol}' must not be empty.";
      }
    ];
    home.packages = map mkDefault activeProtocol.packages ++ [screenshotPkg];
  });
}
