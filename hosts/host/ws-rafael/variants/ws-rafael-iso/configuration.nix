{
  lib,
  pkgs,
  ...
}:
with lib; {
  services = {
    getty.autologinUser = mkForce "rafael";
    kmscon.autologinUser = "rafael";
  };
  users.users.rafael = {
    shell = pkgs.fish;
  };
}
