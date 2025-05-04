{config, ...}: {
  config.lib.utils = {
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
  };
}
