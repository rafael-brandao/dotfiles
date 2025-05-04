{hostcfg, ...}: {
  config.lib.host = {
    info = {
      isDesktop = hostcfg.info.hasAnyTagIn ["desktop" "workstation"];
      isDesktopOrWsl = hostcfg.info.hasAnyTagIn ["desktop" "workstation" "wsl"];
    };
  };
}
