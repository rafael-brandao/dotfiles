{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  programs.ghostty = {
    installBatSyntax = config.programs.bat.enable;
    settings = {
      background-opacity = 0.85;
      command = mkIf config.programs.fish.enable (getExe pkgs.fish);
      cursor-style = "block";
      env = [
        "TERMINAL=ghostty"
      ];
      gtk-titlebar = false;
      shell-integration-features = "no-cursor";
      window-decoration = "none";
    };
  };
}
