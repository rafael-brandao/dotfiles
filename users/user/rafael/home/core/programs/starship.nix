{
  programs.starship = {
    settings = {
      add_newline = false;

      # A minimal left prompt
      format = "$directory$character";

      # move the rest of the prompt to the right
      right_format = "$all";

      command_timeout = 1000;

      character = {
        error_symbol = "[✗](bold red)";
        vicmd_symbol = "[❮](bold green)";
      };

      status = {
        disabled = false;
        format = "[\\[$status\\]]($style)";
      };

      git_branch = {
        format = "[$symbol$branch(:$remote_branch)]($style)";
      };
    };
  };
}
