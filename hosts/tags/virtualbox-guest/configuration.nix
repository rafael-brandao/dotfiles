{
  lib,
  ...
}:
with lib; {
  virtualisation.virtualbox.guest.enable = mkDefault true;
}

