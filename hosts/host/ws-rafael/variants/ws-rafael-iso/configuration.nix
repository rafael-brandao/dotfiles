{pkgs, ...}: {
  services = {
    kmscon.autologinUser = "rafael";
  };
  users.users.rafael = {
    shell = pkgs.fish;
  };
}
