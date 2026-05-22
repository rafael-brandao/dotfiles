{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.xdg;

  terminalLauncher =
    config.rb.defaults.apps.terminalLauncher or {
      enable = false;
      desktopFileId = false;
    };

  mkTerminalCompatShims = let
    terminal-package =
      cfg.terminal-exec.package or pkgs.xdg-terminal-exec;
  in
    name:
      pkgs.writeShellScriptBin name
      # bash
      ''
        args=()
        while [[ $# -gt 0 ]]; do
          case "$1" in
            -T|-name) shift ;;
            *) args+=("$1") ;;
          esac
          shift
        done

        if [ ''${#args[@]} -gt 0 ]; then
          exec ${lib.getExe terminal-package} "''${args[@]}"
        else
          exec ${lib.getExe terminal-package} "$@"
        fi
      '';
in
  mkMerge [
    (mkIf cfg.mimeApps.enable {
      home.packages = with pkgs; [
        dex
        # xdg-launch
        # xdg-utils
      ];
    })

    (mkIf cfg.portal.enable {
      xdg.portal = {
        xdgOpenUsePortal = mkDefault true;

        extraPortals = mkAfter [
          pkgs.xdg-desktop-portal-gtk
        ];
        configPackages = mkAfter [
          pkgs.xdg-desktop-portal-gtk
        ];
        config = {
          common = {
            default = mkAfter ["gtk"];
          };
        };
      };
    })

    (
      mkIf cfg.terminal-exec.enable (
        mkMerge [
          {
            xdg.terminal-exec = {
              package = mkDefault pkgs.xdg-terminal-exec;
            };
          }
          (mkIf (terminalLauncher.enable && terminalLauncher.desktopFileId != null) {
            xdg.terminal-exec = {
              settings = {
                default = mkAfter [
                  terminalLauncher.desktopFileId
                ];
              };
            };
            home.packages = with pkgs; [
              (mkTerminalCompatShims "x-terminal-emulator")
              (mkIf (terminalLauncher.desktopFileId != "xterm.desktop") (mkTerminalCompatShims "xterm"))
            ];
          })
        ]
      )
    )
  ]
