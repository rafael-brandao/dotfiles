{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.map-ssh-identities;

  identityModule = types.submodule {
    options = {
      identityFile = mkOption {
        type = types.path;
        apply = toString;
        description = ''
          The file that contains the identity to be mapped as a directory in ${cfg.identitiesPath}
        '';
      };
      keyType = mkOption {
        type = types.enum ["ed25519" "rsa"];
        default = "ed25519";
        description = "SSH key type";
      };
      privateKeyPath = mkOption {
        type = types.path;
        apply = toString;
        description = "SSH private key path";
      };
      publicKeyPath = mkOption {
        type = types.path;
        apply = toString;
        description = "SSH public key path";
      };
    };
  };
  script = let
    # binaries
    cat = getExe' pkgs.coreutils "cat";
    dirname = getExe' pkgs.coreutils "dirname";
    echo = getExe' pkgs.coreutils "echo";
    find = getExe pkgs.findutils;
    ln = getExe' pkgs.coreutils "ln";
    mkdir = getExe' pkgs.coreutils "mkdir";

    identityFiles = map (identity: identity.identityFile) cfg.identities;

    toBashArray = config.lib.utils.toShellArray {applyFn = file: "\"$(${cat} '${file}')\"";};

    mapIdentities = map (identity:
      # shell
      ''
        link_identity '${identity.identityFile}' '${identity.keyType}' '${identity.privateKeyPath}' '${identity.publicKeyPath}'
      '');

    mapGitAllowedSigners = map (identity:
      # shell
      ''
        ${echo} "$(${cat} ${identity.identityFile}) namespaces=\"git\" $(${cat} ${identity.publicKeyPath})" >> '${cfg.git.allowedSignersFile}'
      '');
  in
    pkgs.writeShellScript "map-ssh-identities" (
      # bash
      ''
        # Define the paths
        declare IDENTITIES_DIR="${cfg.identitiesPath}"
        declare -a IDENTITIES=${toBashArray identityFiles}

        contains_identity() {
          for element in "''${IDENTITIES[@]}"; do
            [ "$element" != "$1" ] || return 0
          done
          return 1
        }

        link_identity() {
          local identity=$(${cat} "$1")
          local identityDir="$IDENTITIES_DIR/$identity"
          local keyType="$2"
          local privateKeyPath="$3"
          local publicKeyPath="$4"

          [ -d "$identityDir" ] || ${mkdir} --parents "$identityDir"
          ${ln} --symbolic --force "$privateKeyPath" "$identityDir/id_$keyType"
          ${ln} --symbolic --force "$publicKeyPath" "$identityDir/id_$keyType.pub"
        }

        [ -d "$IDENTITIES_DIR" ] || ${mkdir} --parents "$IDENTITIES_DIR"

        # Remove existing identity directories that are no longer needed
        ${find} "$IDENTITIES_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename --multiple {} + |
          while read -r identity_dir; do
            contains_identity "$identity_dir" || rm --recursive --force "$identity_dir"
          done

        ${flipPipe [mapIdentities concatStrings] cfg.identities}
      ''
      + (
        optionalString cfg.git.mapAllowedSigners
        # bash
        ''
          # Taken from https://docs.gitlab.com/ee/user/project/repository/signed_commits/ssh.html
          # Declaring the `git` namespace helps prevent cross-protocol attacks.
          declare GIT_ALLOWED_SIGNERS_DIR="$(${dirname} '${cfg.git.allowedSignersFile}')"
          [ -d "$GIT_ALLOWED_SIGNERS_DIR" ] || ${mkdir} --parents "$GIT_ALLOWED_SIGNERS_DIR"
          > ${cfg.git.allowedSignersFile}
          ${flipPipe [mapGitAllowedSigners concatStrings] cfg.identities}
        ''
      )
    );
in {
  options.services.map-ssh-identities = {
    identitiesPath = mkOption {
      type = types.path;
      apply = toString;
      default = "${config.home.homeDirectory}/.ssh/identities";
      description = ''
        The directory to which ssh identities will be mapped
      '';
    };
    identities = mkOption {
      type = types.listOf identityModule;
      default = [];
      description = "List of identities to be mapped to ${cfg.identitiesPath}";
    };
    git = {
      mapAllowedSigners =
        mkEnableOption "Create a git allowed signers file"
        // {
          default = config.programs.git.enable;
        };
      allowedSignersFile = mkOption {
        type = types.path;
        apply = toString;
        default = "${config.xdg.configHome}/git/allowed_signers";
        description = ''
          The directory to which ssh identities will be mapped
        '';
      };
    };
  };

  config = mkIf (length cfg.identities > 0) {
    home.activation.map-ssh-identities = mkIf pkgs.stdenv.isLinux (
      config.lib.utils.restartSystemdService "map-ssh-identities"
    );
    systemd.user.services.map-ssh-identities = mkIf pkgs.stdenv.hostPlatform.isLinux {
      Unit = {
        Description = "map-ssh-identities";
        After = ["sops-nix.service"];
        PartOf = ["sops-nix.service"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = toString script;
      };
      Install.WantedBy = mkIf config.sops.enable config.systemd.user.services.sops-nix.Install.WantedBy;
    };
  };
}
