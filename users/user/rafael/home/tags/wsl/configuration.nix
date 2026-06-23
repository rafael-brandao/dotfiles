{pkgs, ...}: {
  home.sessionVariables = {
    PINENTRY_USER_DATA = "type=tty";
    GPG_TTY = "$(tty)";
  };
  home.packages = [
    pkgs.pinentry-tty
  ];
}
