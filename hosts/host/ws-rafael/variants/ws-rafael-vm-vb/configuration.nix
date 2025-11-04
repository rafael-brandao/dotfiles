{}
#
#
#
# TODO: possibly create a module to abstract these mounts per user
#
# {
#   config,
#   hostcfg,
#   lib,
#   ...
# }:
# with lib; let
#   # User → List of mount configs
#   userMounts = {
#     rafael = [
#       {
#         relativeMountPoint = "Host/Personal";
#         device = "wsl-nixos-rafael-personal";
#         fsType = "9p";
#         options = [
#           "trans=virtio" # fast transport
#           "version=9p2000.L" # modern protocol
#           "msize=262144" # large packets
#           "nofail" # don't fail boot
#           "x-systemd.automount" # mount on first access
#           "cache=loose" # good for WSL
#         ];
#       }
#     ];
#   };
#
#   # Function: generate tmpfiles rules for nested mount point
#   generateTmpfiles = username: relativeMountPoint: let
#     user = config.users.users.${username};
#
#     segments = pipe relativeMountPoint [
#       (splitString "/")
#       (filter (s: s != ""))
#     ];
#
#     relativePaths = let
#       foldFn = acc: segment: let
#         currentPath =
#           if acc == []
#           then segment
#           else (last acc) + "/${segment}";
#       in
#         acc ++ [currentPath];
#     in
#       foldl' foldFn [] segments;
#   in
#     map (p: "${user.home}/${p}") relativePaths;
#
#   # Per-user: collect paths + filesystem entries → deduplicate paths
#   perUserMountConfigs = pipe userMounts [
#     attrsToList
#     (map (
#       {
#         name,
#         value,
#       }: let
#         username = name;
#         mounts = value;
#         user = config.users.users.${username};
#         home = hostcfg.userSettings.${username}.homeDirectory;
#         # inherit (user) home; # TODO: this is necessary to make this not dependable on hostcfg, but it produces infinite recursion error
#       in {
#         tmpfilesRules = pipe mounts [
#           (map (mount: generateTmpfiles username mount.relativeMountPoint))
#           concatLists
#           unique
#           (map (path: "d ${path} 0755 ${username} ${user.group} -"))
#         ];
#
#         fsEntries = pipe mounts [
#           (map (mount: {
#             name = "${home}/${mount.relativeMountPoint}";
#             value = removeAttrs mount ["relativeMountPoint"];
#           }))
#           listToAttrs
#         ];
#       }
#     ))
#   ];
# in {
#   boot = {
#     kernelParams = [
#       "fbcon=nodefer"
#     ];
#   };
#
#   # Merge all per-user fileSystems
#   fileSystems = mkMerge (map (c: c.fsEntries) perUserMountConfigs);
#
#   # Merge all per-user tmpfiles rules
#   systemd.tmpfiles.rules = mkMerge (map (c: c.tmpfilesRules) perUserMountConfigs);
# }
