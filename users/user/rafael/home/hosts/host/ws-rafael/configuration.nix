{
  pkgs,
  ...
}: {
  programs = {
    dank-material-shell.enable = true;
  };

  rb.screenshot.enable = true;

  wayland = {
    windowManager.mango.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-wlr
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-wlr
    ];
    config = {
      common = {
        # Use WLR specifically for screen sharing/casting
        "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
        "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
      };
    };
  };
}
