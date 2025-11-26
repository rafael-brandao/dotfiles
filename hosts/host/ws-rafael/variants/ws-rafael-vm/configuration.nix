{
  pkgs,
  lib,
  ...
}:
with lib; {
  boot = {
    kernelParams = [
      "i915.enable_guc=3" # GuC/HuC firmware
    ];
  };
  services = {
    avahi = {
      publish.enable = true;
      publish.userServices = true;
    };
    getty.autologinUser = "rafael";
    spice-autorandr.enable = true;
    spice-vdagentd.enable = true;
    spice-webdavd.enable = true;
    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
      settings = {
        # ← this is the only line you need for userland audio
        audio_sink = "";
        # (optional but nice)
        channels = "stereo"; # or "5.1" / "7.1" if you ever want surround
      };
      applications = {
        env = {
          PATH = "$(PATH):$(HOME)/.local/bin";
        };
        apps = [
          {
            name = "Client Resolution Desktop";
            auto-detach = true;
            exclude-global-prep-cmd = false;
            exit-timeout = 5;
            image-path = "desktop.png";
            prep-cmd = [
              {
                do = "/bin/sh -c \"${getExe pkgs.wlr-randr} --output HDMI-A-2 --mode \${SUNSHINE_CLIENT_WIDTH}x\${SUNSHINE_CLIENT_HEIGHT}@\${SUNSHINE_CLIENT_FPS}\"";
                undo = "";
              }
            ];
          }
        ];
      };
    };
  };
}
