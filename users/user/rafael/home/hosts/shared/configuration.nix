{}
# {
#   config,
#   lib,
#   ...
# }:
# with lib;
#   mkIf config.sops.enable {
#     sops.secrets = {
#       "ssh/id_ed25519" = {
#         path = "${config.home.homeDirectory}/.ssh/id_ed25519";
#         mode = "0600";
#       };
#       "ssh/id_ed25519.pub" = {
#         path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
#         mode = "0644";
#       };
#     };
#   }
