# rb/dank-material-shell.nix
#
# Local home-manager module that layers override files on top of the upstream
# dank-material-shell home-manager module's generated settings and session.
#
# How the upstream module works (from source)
# ────────────────────────────────────────────
# settings.json   → xdg.configFile, source = jsonFormat.generate "settings.json" cfg.settings
# session.json    → xdg.stateFile,  source = jsonFormat.generate "session.json"  cfg.session
#
# Both land as read-only symlinks into the Nix store.  dms cannot write back to
# them at runtime, and our ExecStartPre cannot write to them either.
#
# Design contract
# ───────────────
# module-settings.json   Nix-owned, never touched at runtime.  Written on every
#   (~/.config/DankMaterialShell/)  generation switch as a stable reference copy
#                        of dmsCfg.settings.  The authoritative merge base.
#
# module-session.json    Same guarantee, for session.
#   (~/.local/state/DankMaterialShell/)
#
# settings.json          Runtime file dms reads.  On every service start,
#   (~/.config/DankMaterialShell/)  ExecStartPre deep-merges module-settings.json
#                        with each path in `settingsOverrides` (in order) and
#                        writes the result here.  May be further mutated by dms
#                        at runtime (UI state persistence, etc.).
#
# session.json           Same, for session.
#   (~/.local/state/DankMaterialShell/)
#
# On every `home-manager switch`
# ───────────────────────────────
#   1. Upstream module writes settings.json / session.json as nix-store symlinks
#      (read-only).  force = true ensures home-manager overwrites them
#      unconditionally on every generation switch without creating backups.
#   2. This module writes module-settings.json / module-session.json as
#      nix-store symlinks (read-only, intentionally stable).
#   3. systemd restarts dms (if restartIfChanged = true on the caller's service
#      config, or via an explicit `systemctl --user restart dms`).
#   4. ExecStartPre re-merges from the always-clean module-*.json base.
{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.rb.programs.dank-material-shell;
  dmsCfg = config.programs.dank-material-shell;

  jsonFormat = pkgs.formats.json {};

  configDir = "${config.xdg.configHome}/DankMaterialShell";
  stateDir = "${config.xdg.stateHome}/DankMaterialShell";

  jq = getExe pkgs.jq;
  cat = getExe' pkgs.coreutils "cat";

  # ── merge script factory ────────────────────────────────────────────────────
  # Returns a store-path shell script that:
  #   1. Reads `base` (a module-*.json path — always current-generation, clean).
  #   2. Deep-merges each element of `overrides` in order (later wins on conflict).
  #   3. Writes the result atomically to `target` via a .tmp + mv.
  #
  # Graceful degradation:
  #   • Missing base  → warn and exit 0 (let dms create its own defaults).
  #   • Missing override → warn and skip (e.g. sops secret not yet available).
  #   • jq parse/merge failure → warn and keep the previous accumulator.
  mkMergeScript = {
    base,
    overrides,
    target,
    label,
  }:
    pkgs.writeShellScript "dms-merge-${label}" (
      # bash
      ''
        set -o nounset    # Fail on use of unset variable.
        set -o errexit    # Exit on command failure.
        set -o pipefail   # Exit on failure of any command in a pipeline.
        set -o errtrace   # Trap errors in functions and subshells.

        if [[ ! -f "${base}" ]]; then
          echo "dms-overrides: base ${base} not found — skipping ${label} merge" >&2
          exit 0
        fi

        CURRENT=$(< "${base}")

      ''
      + concatMapStringsSep "\n" (path:
        # bash
        ''
          if [[ -f "${path}" ]]; then
            if MERGED=$(${jq} --slurp '.[0] * .[1]' <(echo "$CURRENT") "${path}"); then
              CURRENT="$MERGED"
              echo "dms-overrides: merged ${path} into ${label}"
              echo "$CURRENT" | ${jq} --sort-keys '.'
              echo "======================================"
            else
              echo "dms-overrides: jq merge of ${path} failed — keeping previous ${label}" >&2
            fi
          else
            echo "dms-overrides: override ${path} not found — skipping" >&2
          fi
        '')
      overrides
      +
      # bash
      ''

        TMP="${target}.tmp"
        echo "$CURRENT" | ${jq} --sort-keys '.' > "$TMP"
        echo "dms-overrides: final ${label} contents:"
        ${cat} "$TMP"
        mv "$TMP" "${target}"
        echo "dms-overrides: ${label} written → ${target}"
      ''
    );

  # ── combined ExecStartPre script ────────────────────────────────────────────
  applyOverridesScript =
    pkgs.writeShellScript "dms-apply-overrides"
    # bash
    ''
      set -o nounset    # Fail on use of unset variable.
      set -o errexit    # Exit on command failure.
      set -o pipefail   # Exit on failure of any command in a pipeline.
      set -o errtrace   # Trap errors in functions and subshells.

      ${mkMergeScript {
        base = "${configDir}/module-settings.json";
        overrides = cfg.settingsOverrides;
        target = "${configDir}/settings.json";
        label = "settings";
      }}
      ${mkMergeScript {
        base = "${stateDir}/module-session.json";
        overrides = cfg.sessionOverrides;
        target = "${stateDir}/session.json";
        label = "session";
      }}
    '';
in {
  # ── options ──────────────────────────────────────────────────────────────────
  options.rb.programs.dank-material-shell = {
    settingsOverrides = mkOption {
      type = with types; listOf str;
      default = [];
      description = ''
        Ordered list of JSON files to deep-merge into the upstream module's
        generated settings.  Later entries override earlier ones.  The merged
        result is written to settings.json immediately before dms starts.

        The merge base is always module-settings.json — the current generation's
        clean copy of programs.dank-material-shell.settings.  Runtime mutations
        by dms never bleed into subsequent merges.

        Typical use: a sops-nix secret containing only the keys that must stay
        out of your public dotfiles repository, e.g.:

          config.sops.secrets."dms/weather".path
            → { "weatherCoordinates": "25.7617, -80.1918",
                "weatherLocation":    "Miami, FL" }
      '';
      example = literalExpression ''
        [ config.sops.secrets."dms/weather".path ]
      '';
    };

    sessionOverrides = mkOption {
      type = with types; listOf str;
      default = [];
      description = ''
        Ordered list of JSON files to deep-merge into the upstream module's
        generated session.  Later entries override earlier ones.  The merged
        result is written to session.json immediately before dms starts.

        The merge base is always module-session.json.
      '';
      example = literalExpression ''
        [ ./session-extras.json ]
      '';
    };
  };

  # ── implementation ───────────────────────────────────────────────────────────
  config = mkIf dmsCfg.enable {
    # ── 1. module-settings.json / module-session.json ─────────────────────────
    #
    # These are nix-store symlinks (like the upstream settings.json / session.json)
    # but they are NEVER overwritten by force = true — they stay read-only
    # permanently.  On every generation switch home-manager restores them to the
    # current generation's content, giving ExecStartPre a clean, stable merge
    # base regardless of what dms wrote to settings.json / session.json at
    # runtime.
    #
    # Content is derived directly from dmsCfg.settings / dmsCfg.session so there
    # is a single source of truth in the caller's config.
    #
    # ── 2. settings.json / session.json — force = true ────────────────────────
    #
    # The upstream module writes settings.json / session.json as nix-store
    # symlinks.  At runtime dms mutates them freely (UI state persistence, etc.),
    # leaving plain mutable files where home-manager expects its own symlinks.
    #
    # On the next generation switch home-manager would try to back up the
    # diverged plain files before replacing them — but if a backup already exists
    # from a previous switch, activation fails.
    #
    # force = true tells home-manager to overwrite settings.json / session.json
    # unconditionally without creating a backup.  This is safe because:
    #   a) Their content is always regenerated from module-settings.json /
    #      module-session.json by ExecStartPre on every service start.
    #   b) Any runtime state dms wrote to them is intentionally ephemeral —
    #      it does not need to survive a generation switch.
    xdg = {
      configFile = {
        "DankMaterialShell/module-settings.json" = mkIf (dmsCfg.settings != {}) {
          source = jsonFormat.generate "module-settings.json" dmsCfg.settings;
        };
        "DankMaterialShell/settings.json" = mkIf (dmsCfg.settings != {}) {
          force = true;
        };
      };

      stateFile = {
        "DankMaterialShell/module-session.json" = mkIf (dmsCfg.session != {}) {
          source = jsonFormat.generate "module-session.json" dmsCfg.session;
        };
        "DankMaterialShell/session.json" = mkIf (dmsCfg.session != {}) {
          force = true;
        };
      };
    };

    # ── 3. dms-pre — merge on every dms start ────────────────────────────────
    #
    # dms-pre.service is a oneshot service that is PartOf dms.service — it
    # starts and stops with dms, is pulled in automatically via WantedBy, and
    # runs before dms.service via Before/Requires.
    #
    # Timeline on each boot or `systemctl --user restart dms`:
    #
    #   home-manager activation
    #     → upstream overwrites settings.json / session.json (force = true)
    #     → this module writes module-*.json as store symlinks
    #   systemd starts dms.service
    #     → pulls in dms-pre.service (WantedBy)
    #     → dms-pre.service fires:
    #          reads  module-settings.json   (read-only store symlink, always clean)
    #          merges cfg.settingsOverrides  (runtime paths, store paths, etc.)
    #          writes settings.json          (mutable plain file, what dms reads)
    #          same for session
    #     → ExecStart: dms run --session
    #
    # Note: sops-aware services (e.g. dms-weather-secret) declare themselves
    # Before=dms-pre.service independently — dms-pre has no knowledge of them.
    systemd.user.services = mkIf dmsCfg.systemd.enable {
      dms-pre = mkIf dmsCfg.systemd.enable {
        Unit = {
          Description = "DankMaterialShell pre-start config merge";
          After = ["sops-nix.service"];
          Before = ["dms.service"];
          PartOf = ["dms.service"];
        };

        Service = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${applyOverridesScript}";
        };

        Install.WantedBy = ["dms.service"];
      };

      dms = {
        Unit = {
          After = ["dms-pre.service"];
          Requires = ["dms-pre.service"];
        };
      };
    };
  };
}
