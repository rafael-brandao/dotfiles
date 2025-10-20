{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.gopass;

  ageIdentityModule = types.submodule {
    options = {
      keyType = mkOption {
        type = types.enum ["age" "ssh"];
        default = "age";
        description = "Age identity key type, either age or ssh";
      };
      privateKeyPath = mkOption {
        type = types.path;
        apply = toString;
        description = "Private key path";
      };
    };
  };

  ageInteractivePasswd = let
    age = getExe' pkgs.age "age";
    bash = getExe' pkgs.bash "bash";
    cat = getExe' pkgs.coreutils "cat";
    expect = getExe' pkgs.expect "expect";
  in
    pkgs.writeScript "age-interactive-encrypt"
    # tcl
    ''
      #! ${expect}

      set timeout 5
      set inputFile [lindex $argv 0]
      set outputFile [lindex $argv 1]
      set passphrase $env(AGE_PASS)

      spawn ${bash} -c "${cat} '$inputFile' | ${age} --passphrase --output '$outputFile'"
      expect "Enter passphrase (leave empty to autogenerate a secure one): "
      send -- "$passphrase\r"
      expect "Confirm passphrase: "
      send -- "$passphrase\r"
      expect eof
    '';

  concatenateAgeIdentities = let
    cat = getExe' pkgs.coreutils "cat";
    mkdir = getExe' pkgs.coreutils "mkdir";
    ssh-to-age = getExe pkgs.ssh-to-age;

    getKeyPathsWhereKeyTypeIs = keyType:
      pipe cfg.age.identities [
        (filter (identity: identity.keyType == keyType))
        (map (identity: identity.privateKeyPath))
      ];

    ageKeyPaths = getKeyPathsWhereKeyTypeIs "age";
    sshKeyPaths = getKeyPathsWhereKeyTypeIs "ssh";

    toBashArray = config.lib.utils.toShellArray {applyFn = path: "'${path}'";};
  in
    pkgs.writeShellScript "concatenate-gopass-age-identities"
    # bash
    ''
      set -Eeuo pipefail

      # Define the paths
      declare IDENTITIES_DIR="${cfg.configHome}/age"
      declare IDENTITIES_FILE="$IDENTITIES_DIR/identities"
      declare -a AGE_KEY_PATHS=${toBashArray ageKeyPaths}
      declare -a SSH_KEY_PATHS=${toBashArray sshKeyPaths}

      [ "''${#AGE_KEY_PATHS[@]}" -gt 0 ] || [ "''${#SSH_KEY_PATHS[@]}" -gt 0 ] || exit 0

      ${mkdir} --parents "$IDENTITIES_DIR"
      > "$IDENTITIES_FILE"

      for ageKeyPath in "''${AGE_KEY_PATHS[@]}"; do
        ${cat} "$ageKeyPath" >> "$IDENTITIES_FILE"
      done

      for sshKeyPath in "''${SSH_KEY_PATHS[@]}"; do
        ${ssh-to-age} -private-key -i "$sshKeyPath" >> "$IDENTITIES_FILE"
      done

      AGE_PASS="$(${cat} '${cfg.age.passwordFile}')" ${toString ageInteractivePasswd} "$IDENTITIES_FILE" "$IDENTITIES_FILE"
      [ -z "''${AGE_PASS+x}" ] || unset AGE_PASS
    '';
in {
  options.programs.gopass = {
    enable = mkEnableOption "gopass, the slightly more awesome standard unix password manager for teams";

    enableGitIntegration = mkEnableOption "Whether to enable git integration as a password store";

    enableJsonapi = mkEnableOption "Whether to install gopass-jsonapi package";

    enableLibSecretIntegration = mkEnableOption "Whether to enable gopass integration with libsecret";

    configHome = mkOption {
      type = types.path;
      default = "${config.xdg.configHome}/gopass";
      apply = toString;
      description = "The absolute path of the directory containing the the .config/ tree";
    };

    configFile = mkOption {
      type = types.path;
      default = "${cfg.configHome}/config";
      apply = toString;
      readOnly = true;
      internal = true;
      description = "The absolute path of the gopass configuration file";
    };

    age = {
      identities = mkOption {
        type = types.listOf ageIdentityModule;
        default = [];
        description = "List of age identities to be mapped from their private keys";
      };
      passwordFile = mkOption {
        type = with types; nullOr path;
        apply = p:
          if p == null
          then p
          else toString p;
        description = "Path that points to the password file that will be used when creating the identities file";
      };
    };

    rootStorePath = mkOption {
      type = types.path;
      default = "${config.xdg.dataHome}/gopass/stores/root";
      apply = toString;
      description = "Path to the root store";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home = {
        packages = [pkgs.gopass];
      };
      # xdg.configFile."gopass/config.yml".text = pipe cfg.settings [
      #   (filterAttrs (key: value: value != null))
      #   (lib.generators.toYAML { })
      # ];
    }

    (mkIf (pkgs.stdenv.hostPlatform.isLinux && config.sops.secrets != {} && cfg.age.identities != []) {
      home.activation.setup-gopass = config.lib.utils.restartSystemdService "setup-gopass";
      systemd.user.services.setup-gopass = {
        Unit = {
          Description = "setup-gopass";
          After = ["sops-nix.service"];
          PartOf = ["sops-nix.service"];
        };
        Service = {
          Type = "oneshot";
          ExecStart = toString concatenateAgeIdentities;
        };
        Install.WantedBy = config.systemd.user.services.sops-nix.Install.WantedBy;
      };
    })

    (mkIf cfg.enableGitIntegration {
      home.packages = [
        pkgs.git-credential-gopass # manage git credentials using gopass
      ];
      programs.git.settings = {
        credential.helper = mkOverride 500 "gopass";
      };
    })

    (mkIf cfg.enableLibSecretIntegration {
      programs.password-store = {
        enable = mkOverride 500 true;
        settings = {
          PASSWORD_STORE_DIR = mkOverride 500 (toString cfg.rootStorePath);
        };
      };
      services.pass-secret-service.enable = mkOverride 500 true;
    })
  ]);
}
