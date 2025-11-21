{
  inputs,
  lib,
  pkgs,
  ...
}:
with lib; {
  home = {
    packages = with pkgs; [
      coreutils
      dwt1-shell-color-scripts
      gawk
      gnused
      lolcat
    ];
    # sessionVariables = {
    #   SHELL = "fish";
    # };
  };

  programs.fish = {
    shellInit =
      # fish
      ''
        # Shell intialization

        # export
        set fish_greeting # Supresses fish's intro message

        # end of shell intialization
      '';

    interactiveShellInit =
      # fish
      ''
          # set blinking block cursor
          function set_block_blinking_cursor --on-event fish_prompt
            echo -en "\e[1 q"
          end

          function fish_user_key_bindings
            # Call vi bindings first
            fish_vi_key_bindings
          end

          # Functions needed for !! and !$
          function __history_previous_command
              switch (commandline -t)
              case "!"
                commandline -t $history[1]; commandline -f repaint
              case "*"
                commandline -i !
              end
          end

          function __history_previous_command_arguments
              switch (commandline -t)
              case "!"
                commandline -t ""
                commandline -f history-token-search-backward
              case "*"
                commandline -i '$'
              end
          end

          # The bindings for !! and !$
          if [ $fish_key_bindings = fish_vi_key_bindings ];
              bind -Minsert ! __history_previous_command
              bind -Minsert '$' __history_previous_command_arguments
          else
              bind ! __history_previous_command
              bind '$' __history_previous_command_arguments
          end

        # random color script
        colorscript random
      '';

    functions = {
      __history_previous_command = {
        description = ''
          Needed for keybinding !!
        '';
        body =
          # fish
          ''
            switch (commandline -t)
              case "!"
                commandline -t $history[1]; commandline -f repaint
              case "*"
                commandline -i !
            end
          '';
      };

      __history_previous_command_arguments = {
        description = ''
          Needed for keybinding !\$
        '';
        body =
          # fish
          ''
            switch (commandline -t)
              case "!"
                commandline -t ""
                commandline -f history-token-search-backward
              case "*"
                commandline -i '$'
            end
          '';
      };

      # fish_user_key_bindings = {
      #   body = /* fish */ ''
      #     fish_vi_key_bindings
      #   '';
      # };

      letters = {
        body =
          # fish
          ''
            cat $argv | awk -vFS=''' '{for(i=1;i<=NF;i++){ if($i~/[a-zA-Z]/) { w[tolower($i)]++} } }END{for(i in w) print i,w[i]}' | sort | cut -c 3- | spark | lolcat
            printf  '%s\n' 'abcdefghijklmnopqrstuvwxyz'  ' ' | lolcat
          '';
      };

      commits = {
        body =
          # fish
          ''
            git log --author="$argv" --format=format:%ad --date=short | uniq -c | awk '{print $1}' | spark | lolcat
          '';
      };

      backup = {
        description = ''
          Function for creating a backup file
          ex: backup file.txt
          result: copies file as file.txt.bak
        '';

        argumentNames = ["filename"];

        body =
          # fish
          ''
            cp $filename $filename.bak
          '';
      };

      copy = {
        description = ''
          Function for copying files and directories, even recursively.
          ex: copy DIRNAME LOCATIONS
          result: copies the directory and all of its contents.
        '';
        body =
          # fish
          ''
            set count (count $argv | tr -d \n)
            if test "$count" = 2; and test -d "$argv[1]"
              set from (echo $argv[1] | trim-right /)
              set to (echo $argv[2])
              command cp -r $from $to
            else
              command cp $argv
            end
          '';
      };

      coln = {
        description = ''
          Function for printing a column (splits input on whitespace)
          ex: echo 1 2 3 | coln 3
          output: 3
        '';
        body =
          # fish
          ''
            while read -l input
              echo $input | awk '{print $'$argv[1]'}'
            end
          '';
      };

      rown = {
        description = ''
          Function for printing a row
          ex: seq 3 | rown 3
          output: 3
        '';
        argumentNames = ["index"];
        body =
          # fish
          ''
            sed -n "$index p"
          '';
      };

      skip = {
        description = ''
          Function for ignoring the first 'n' lines
          ex: seq 10 | skip 5
          results: prints everything but the first 5 lines
        '';
        argumentNames = ["n"];
        body =
          # fish
          ''
            tail +(math 1 + $n)
          '';
      };

      take = {
        description = ''
          Function for taking the first 'n' lines
          ex: seq 10 | take 5
          results: prints only the first 5 lines
        '';
        argumentNames = ["number"];
        body =
          # fish
          ''
            head -$number
          '';
      };

      history = {
        body =
          # fish
          ''
            builtin history --show-time='%F %T    '
          '';
      };
    };

    plugins = [
      {
        name = "spark";
        src = inputs.fish-plugin-spark;
      }
    ];
  };
}
