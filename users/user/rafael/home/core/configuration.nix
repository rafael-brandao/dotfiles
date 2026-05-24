{lib, ...}: with lib; {
  imports = [
    ./secrets
    ./misc
    ./programs
    ./services
  ];

  home.file.".profile".text = mkBefore
  # bash
  ''
    if [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
      . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    fi
  '';
}
