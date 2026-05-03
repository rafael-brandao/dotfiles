{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.wayland.windowManager.mango;
in {
  imports = [
    ./mangowc/bindings.nix
    ./mangowc/colors.nix
  ];

  config = mkIf cfg.enable {
    wayland.windowManager.mango = {
      autostart_sh =
        # bash
        ''

          echo 'Starting MangoWC'
        '';
      bottomPrefixes = ["source"];
      settings = {
        # Tag rules
        tagrule = [
          "id:1,layout_name:scroller"
          "id:2,layout_name:scroller"
          "id:3,layout_name:scroller"
          "id:4,layout_name:scroller"
          "id:5,layout_name:scroller"
          "id:6,layout_name:scroller"
          "id:7,layout_name:scroller"
          "id:8,layout_name:scroller"
          "id:9,layout_name:scroller"
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

        # Scroller Layout Setting
        edge_scroller_pointer_focus = 1;
        scroller = {
          default_proportion = 0.8;
          default_proportion_single = 1.0;
          focus_center = 0;
          prefer_center = 1;
          proportion_preset = "0.5,0.8,1.0";
          structs = 20;
        };

        # Master-Stack Layout Setting
        default_mfact = 0.55;
        default_nmaster = 1;
        new_is_master = 1;
        smartgaps = 0;

        # Overview Setting
        enable_hotarea = 1;
        hotarea_size = 10;
        ov_tab_mode = 0;
        overviewgappi = 5;
        overviewgappo = 30;

        # Misc
        axis_bind_apply_timeout = 100;
        circle_layout = "tile,scroller";
        cursor = {
          hide_timeout = 1;
        };
        drag_tile_to_tile = 1;
        enable_floating_snap = 1;
        focus = {
          cross = {
            monitor = 0;
            tag = 0;
          };
          on_activate = 1;
        };
        no_border_when_single = 0;
        single_scratchpad = 1;
        sloppyfocus = 1;
        snap_distance = 50;
        syncobj_enable = 0;
        warpcursor = 1;
        xwayland_persistence = 1;

        # keyboard
        numlockon = 1;
        repeat = {
          delay = 600;
          rate = 25;
        };

        # Trackpad
        accel = {
          profile = 2;
          speed = 0.0;
        };
        disable = {
          trackpad = 0;
          while_typing = 1;
        };
        drag_lock = 1;
        left_handed = 0;
        middle_button_emulation = 0;
        mouse_natural_scrolling = 0;
        scroll = {
          button = 274;
          method = 1;
        };
        swipe_min_threshold = 1;
        tap_and_drag = 1;
        tap_to_click = 1;
        trackpad_natural_scrolling = 1;

        # Appearance
        borderpx = 4;
        gappih = 5;
        gappiv = 5;
        gappoh = 5;
        gappov = 5;
        scratchpad = {
          height_ratio = 0.9;
          width_ratio = 0.8;
        };
      };
    };

    home.sessionVariablesExtra =
      #bash
      ''
        # Start mango on the first virtual terminal without a display running
        if [ -z "''${WAYLAND_DISPLAY}" ] && [ -z "''${DISPLAY}" ] && [ "''${XDG_VTNR}" -eq 1 ]; then
          exec mango
        fi
      '';
  };
}
