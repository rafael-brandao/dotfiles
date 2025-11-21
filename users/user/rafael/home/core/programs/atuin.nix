{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.atuin;
in
  mkIf cfg.enable (
    mkMerge [
      {
        programs.atuin = {
          daemon.enable = mkDefault true;
          enableFishIntegration = mkDefault config.programs.fish.enable;
          flags = [
            "--disable-up-arrow"
          ];
          settings = {
            ctrl_n_shortcuts = mkDefault true;
            enter_accept = mkDefault true;
            inline_height = mkDefault 13;
            invert = mkDefault true;
            show_help = mkDefault false;
            style = mkDefault "compact";
          };
        };
      }
      (mkIf config.sops.enable {
        systemd.user.services = {
          atuin-login = {
            Unit = {
              Description = "atuin-login";
              After = ["sops-nix.service"];
              PartOf = ["sops-nix.service"];
            };
            Service = {
              Type = "oneshot";
              Environment = with pkgs; ["PATH=${makeBinPath [atuin coreutils]}"];
              ExecStartPre = "/bin/sh -c 'atuin logout'";
              ExecStart = with config.sops; ''
                /bin/sh -c 'atuin login \
                  --key "$(cat ${secrets."atuin/key".path})" \
                  --username "$(cat ${secrets."atuin/username".path})" \
                  --password "$(cat ${secrets."atuin/password".path})"'
              '';
            };
            Install.WantedBy = config.systemd.user.services.sops-nix.Install.WantedBy;
          };
          atuin-sync = {
            Unit = {
              Description = "atuin-sybc";
              After = ["sops-nix.service" "atuin-login.service"];
              PartOf = ["sops-nix.service" "atuin-login.service"];
            };
            Service = {
              Type = "oneshot";
              Environment = with pkgs; ["PATH=${makeBinPath [atuin]}"];
              ExecStart = "/bin/sh -c 'atuin sync'";
            };
            Install.WantedBy = config.systemd.user.services.sops-nix.Install.WantedBy;
          };
        };
      })
    ]
  )
