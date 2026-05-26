{
  config,
  lib,
  ...
}: let
  inherit
    (builtins)
    toJSON
    ;
  inherit
    (lib)
    isPath
    isString
    isInt
    isFloat
    isDerivation
    replaceStrings
    concatMapStringsSep
    ;
in {
  config.lib.utils = rec {
    restartSystemdService = serviceName: let
      systemctl = config.systemd.user.systemctlPath;
    in
      # bash
      ''
        systemdStatus=$(${systemctl} --user is-system-running 2>&1 || true)

        if [[ $systemdStatus == 'running' ]]; then
          ${systemctl} restart --user "${serviceName}"
        else
          echo "User systemd daemon not running. Probably executed on boot where no manual start/reload is needed."
        fi

        unset systemdStatus
      '';

    # Quotes an argument for use in Exec* service lines.
    # systemd accepts "-quoted strings with escape sequences, toJSON produces
    # a subset of these.
    # Additionally we escape % to disallow expansion of % specifiers. Any lone ;
    # in the input will be turned it ";" and thus lose its special meaning.
    # Every $ is escaped to $$, this makes it unnecessary to disable environment
    # substitution for the directive.
    escapeSystemdExecArg = arg: let
      s =
        if isPath arg
        then "${arg}"
        else if isString arg
        then arg
        else if isInt arg || isFloat arg || isDerivation arg
        then toString arg
        else throw "escapeSystemdExecArg only allows strings, paths, numbers and derivations";
    in
      replaceStrings ["%" "$"] ["%%" "$$"] (toJSON s);

    # Quotes a list of arguments into a single string for use in a Exec*
    # line.
    escapeSystemdExecArgs = concatMapStringsSep " " escapeSystemdExecArg;
  };
}
