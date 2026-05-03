{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.wayland.windowManager.mango;
in
  mkIf cfg.enable {
    wayland.windowManager.mango = {
      autostart_sh =
        # bash
        ''
          echo 'Starting MangoWC'
        '';
      settings = {
        # Binds
        bind = [
          "SUPER+SHIFT,r,reload_config"
          "SUPER,Return,spawn,ghostty"
          "SUPER,q,killclient,"
        ];

        # Effects
        blur = 0;
        blur_layer = 1;
        blur_optimized = 1;
        blur_params = {
          brightness = 0.9;
          contrast = 0.9;
          noise = 0.02;
          num_passes = 2;
          radius = 5;
          saturation = 1.2;
        };

        shadows = 1;
        layer_shadows = 1;
        shadow_only_floating = 1;
        shadows_blur = 15;
        shadows_size = 12;
        shadows_position = {
          x = 0;
          y = 0;
        };
        shadowscolor = "0x000000ff";

        border_radius = 6;
        no_radius_when_single = 0;
        focused_opacity = 1.0;
        unfocused_opacity = 0.85;

        # Animation Configuration
        animations = 1;
        animation = {
          curve = {
            close = "0.08,0.92,0,1";
            focus = "0.46,1.0,0.29,1";
            move = "0.46,1.0,0.29,1";
            opafadein = "0.46,1.0,0.29,1";
            opafadeout = "0.58,0.98,0.58,0.98";
            open = "0.46,1.0,0.29,1.1";
            tag = "0.46,1.0,0.29,1";
          };
          duration = {
            close = 800;
            focus = 400;
            move = 500;
            open = 400;
            tag = 350;
          };
          fade = {
            "in" = 1;
            out = 1;
          };
          type = {
            close = "slide";
            open = "zoom";
          };
        };
        fadein_begin_opacity = 0.6;
        fadeout_begin_opacity = 0.8;
        layer_animations = 1;
        layer_animation = {
          type = {
            close = "slide";
            open = "slide";
          };
        };
        tag_animation_direction = 1;
        zoom = {
          initial_ratio = 0.4;
          end_ratio = 0.7;
        };
      };
    };

    home.file.".profile" = {
      text =
        #bash
        ''
          # Start mango on the first virtual terminal without a display running
          if [ -z "''${WAYLAND_DISPLAY}" ] && [ -z "''${DISPLAY}" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
            exec mango
          fi
        '';
    };
  }
