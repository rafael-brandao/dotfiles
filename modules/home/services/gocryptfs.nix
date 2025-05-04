{
  config,
  lib,
  osConfig ? {},
  paths,
  pkgs,
  ...
}:
# TODO: Create extra options to be passed to gocryptfs mount command
with lib; let
  cfg = config.services.gocryptfs;
  defaultMountPath = "${config.xdg.dataHome}/gocryptfs";
  mountList = attrValues cfg.mounts;

  mountOptionsModule = types.submodule {
    options = {
      allowOther =
        mkEnableOption "Allow other users to access the mount."
        // {
          default = attrByPath ["programs" "fuse" "userAllowOther"] false osConfig;
        };
      mountType = mkOption {
        type = types.enum ["forward" "reverse"];
        default = "forward";
        description = "Mount type, either forward or reverse.";
      };
      removeRelativePathOnExit =
        mkEnableOption "Remove any relative paths cretaed for a mount."
        // {
          default = true;
        };
    };
  };

  mountModule = types.submodule ({
    config,
    name,
    ...
  }: {
    options = {
      label = mkOption {
        type = types.str;
        default = name;
        description = ''
          A label that might be used to determine the default paths of
          plain and cypher directories and will be used as the systemd
          service suffix.

          This option receives by default the value of the key used to
          create this mount module.
        '';
      };
      configFile = mkOption {
        type = types.path;
        apply = toString;
        description = ''
          The file that contains the configuration that will be used to mount the filesystem.
        '';
      };
      passwordFile = mkOption {
        type = types.path;
        apply = toString;
        description = ''
          The file that contains the password that unlocks the configuration master key.
        '';
      };
      plainDirectoryPath = mkOption {
        type = types.path;
        default = "${defaultMountPath}/${config.label}/plain";
        description = ''
          The directory path of plain view of the data.

          It might be null if you want this directory to be mounted in default the path
          determined by the label, which then would be:

          ''${config.xdg.dataHome}/gocryptfs/mounts/''${config.label}/plain
        '';
      };
      cypherDirectoryPath = mkOption {
        type = types.path;
        default = "${defaultMountPath}/${config.label}/cypher";
        description = ''
          The directory path of encrypted view of the data.

          It might be null if you want this directory to be mounted in default the path
          determined by the label, which then would be:

          ''${config.xdg.dataHome}/gocryptfs/mounts/''${config.label}/cypher
        '';
      };

      mountOptions = mkOption {
        type = mountOptionsModule;
        default = {};
        description = "Specific options for mounting this submodule.";
      };

      # Readonly Options
      serviceName = mkOption {
        type = types.str;
        readOnly = true;
        default = "gocryptfs-mount-${config.label}";
        description = ''Systemd service name derived from ''${config.label}.'';
      };

      # Internal Options
      sourcePath = mkOption {
        type = types.path;
        apply = toString;
        readOnly = true;
        internal = true;
        default =
          if config.mountOptions.mountType == "forward"
          then config.cypherDirectoryPath
          else config.plainDirectoryPath;
        description = ''
          Source directory to be mounted. If mount type is forward,
          source will be the cypher directory. If mount type is
          reverse, source will be the plain directory.
        '';
      };
      targetPath = mkOption {
        type = types.path;
        apply = toString;
        readOnly = true;
        internal = true;
        default =
          if config.mountOptions.mountType == "reverse"
          then config.cypherDirectoryPath
          else config.plainDirectoryPath;
        description = ''
          Target directory to be mounted. If mount type is forward,
          target will be the plain directory. If mount type is
          reverse, target will be the cypher directory.
        '';
      };
    };
    config.mountOptions = {
      allowOther = mkDefault cfg.defaultMountOptions.allowOther;
      mountType = mkDefault cfg.defaultMountOptions.mountType;
      removeRelativePathOnExit = mkDefault cfg.defaultMountOptions.removeRelativePathOnExit;
    };
  });
in {
  options.services.gocryptfs = {
    inherit (config.lib.module-options) unmount;

    enable =
      mkEnableOption "Service that setups gocryptfs mounts."
      // {
        default = length mountList > 0;
      };

    package = mkPackageOption pkgs "gocryptfs" {};

    mounts = mkOption {
      type = types.attrsOf mountModule;
      default = {};
      description = "Attribute sets of mounts to create systemd services.";
    };

    # TODO: use lib.strings.makeBinPath to simplify this implementation
    path = mkOption {
      type = with types; listOf path;
      default = let
        toBinaryPath = map (pkg: "${pkg}/bin");
        pkgsForPath = toBinaryPath (with pkgs; [
          bash
          cfg.package
          coreutils
          gnugrep
        ]);
      in
        [cfg.unmount.path] ++ pkgsForPath;
      apply = flipPipe [(map toString) (mkString {sep = ":";})];
      description = "Unified paths used in this module.";
    };

    defaultMountOptions = mkOption {
      type = mountOptionsModule;
      default = {};
      description = "Default options for mounting.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [cfg.package];

    systemd.user.services = mkIf pkgs.stdenv.hostPlatform.isLinux (mkMerge (
      forEach mountList (
        m: let
          bash = getExe' pkgs.bash "bash";
          gocryptfs = getExe' cfg.package "gocryptfs";
          foldFn = flip foldl' "" (
            acc: arr:
              if (head arr)
              then "${acc} \\\n  ${elemAt arr 1}"
              else acc
          );
          optionalFlags = foldFn (with m.mountOptions; [
            [allowOther "--allow_other"]
            [(mountType == "reverse") "--reverse"]
          ]);
        in {
          ${m.serviceName} = {
            Unit = {
              Description = m.serviceName;
              After = ["sops-nix.service"];
              PartOf = ["sops-nix.service"];
            };
            Install = {
              WantedBy = ["default.target"];
            };
            Service = {
              Type = "exec";
              ExecStartPre = [
                # "/bin/sh -c '/usr/bin/env > /tmp/gocryptfs_env.txt'"
                "${bash} -c 'mkdir --parents \"${m.sourcePath}\"'"
                "${bash} -c 'mkdir --parents \"${m.targetPath}\"'"
              ];
              ExecStart = ''
                ${gocryptfs} ${optionalFlags} \
                  --fg \
                  --config ${escapeShellArg m.configFile} \
                  --passfile ${escapeShellArg m.passwordFile} \
                  ${escapeShellArg m.sourcePath} \
                  ${escapeShellArg m.targetPath}'';
              ExecStop = "${bash} -c '${cfg.unmount.fusermount.binary} -uz ${escapeShellArg m.targetPath}'";
              ExecStopPost = mkIf m.mountOptions.removeRelativePathOnExit "${paths.scripts}/prune-relative-dir.bash '${m.targetPath}' '${config.home.homeDirectory}'";
              Restart = "always";
              RestartSec = "10s";
              SuccessExitStatus = ["0" "15" "SIGINT"];
              Environment = ["PATH=${cfg.path}"];
            };
          };
        }
      )
    ));
  };
}
