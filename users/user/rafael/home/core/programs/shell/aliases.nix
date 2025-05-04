{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  shells = ["bash" "fish" "nushell" "zsh"];
  enabledShells = filter (shell: config.programs.${shell}.enable) shells;

  aliases = mkMerge [
    {
      # Dirs
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......" = "cd ../../../../..";

      # HTTP requests with xh!
      http = "xh";

      cl = "clear";
      la = "tree --dirsfirst";
      # cat = "bat";

      # Eza
      l = "eza --group-directories-first --long --icons --git --all";
      lt = "eza --group-directories-first --tree --level=2 --long --icons --git";

      # Colorize grep output (good for log files)
      grep = "grep --color=auto";
      egrep = "egrep --color=auto";
      fgrep = "fgrep --color=auto";

      # adding flags
      df = "df -h"; # human-readable sizes
      free = "free -m"; # show sizes in MB

      # get top process eating memory
      psmem = "ps auxf | sort -nr -k 4";
      psmem10 = "ps auxf | sort -nr -k 4 | head -10";

      # get top process eating cpu ##
      pscpu = "ps auxf | sort -nr -k 3";
      pscpu10 = "ps auxf | sort -nr -k 3 | head -10";

      # gpg encryption
      # verify signature for isos
      gpg-check = "gpg2 --keyserver-options auto-key-retrieve --verify ";
      # receive the key of a developer
      gpg-retrieve = "gpg2 --keyserver-options auto-key-retrieve --receive-keys ";

      # youtube-dl
      # FIXME: youtube-dl is unmaintained, migrate to yt-dlp, if possible
      # yta-aac = "youtube-dl --extract-audio --audio-format aac ";
      # yta-best = "youtube-dl --extract-audio --audio-format best ";
      # yta-flac = "youtube-dl --extract-audio --audio-format flac ";
      # yta-m4a = "youtube-dl --extract-audio --audio-format m4a ";
      # yta-mp3 = "youtube-dl --extract-audio --audio-format mp3 ";
      # yta-opus = "youtube-dl --extract-audio --audio-format opus ";
      # yta-vorbis = "youtube-dl --extract-audio --audio-format vorbis ";
      # yta-wav = "youtube-dl --extract-audio --audio-format wav ";
      # ytv-best = "youtube-dl -f bestvideo+bestaudio ";

      # termbin
      tb = "nc termbin.com 9999";

      # the terminal rickroll
      rr = "curl -s -L https://raw.githubusercontent.com/keroserene/rickrollrc/master/roll.sh | ${pkgs.bash}/bin/bash";

      # xclip
      clipboard = "xclip -selection clipboard";
    }

    # Git
    (mkIf config.programs.git.enable {
      g = "git";
    })

    # NeoVim
    (mkIf config.programs.neovim.enable {
      v = "nvim";
    })
  ];
in {
  config = {
    home.packages = with pkgs;
      mkIf (length enabledShells > 0) [
        bat
        curl
        coreutils
        findutils
        fzf
        eza
        gnugrep
        procps
        gnupg
        libressl
        tree
        xclip
        xh
        # FIXME: youtube-dl is unmaintained, migrate to yt-dlp, if possible
        # youtube-dl
      ];

    programs = {
      # shell
      bash = mkIf config.programs.bash.enable {
        shellAliases = aliases;
      };

      # Fish
      fish = mkIf config.programs.fish.enable {
        shellAliases = aliases;

        functions = mkMerge [
          {
            cx = {
              body =
                # fish
                ''
                  cd "$argv"; and l
                '';
            };

            fcd = {
              body =
                # fish
                ''
                  cd (find . -type d -not -path '*/.*' | fzf); and l
                '';
            };

            f = {
              body =
                # fish
                ''
                  echo (find . -type f -not -path '*/.*' | fzf) | xclip -selection clipboard
                '';
            };
          }

          (mkIf config.programs.neovim.enable {
            fv = {
              body =
                # fish
                ''
                  nvim (find . -type f -not -path '*/.*' | fzf)
                '';
            };
          })
        ];
      };

      # NuShell
      nushell = mkIf config.programs.nushell.enable {
        shellAliases = aliases;
      };

      # Zsh
      zsh = mkIf config.programs.zsh.enable {
        shellAliases = aliases;
      };
    };
  };
}
