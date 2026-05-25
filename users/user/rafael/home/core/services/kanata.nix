_: {
  services.kanata = {
    enable = true;
    keyboards = {
      us-ansi = {
        extraDefCfg = "process-unmapped-keys yes";
        config = let
          mkUnicodeFork = c1: c2: "(fork (unicode ${c1}) (unicode ${c2}) (lsft rsft))";
        in ''
          (defvar
            tap-repress-timeout 250
            hold-timeout 250
            tt $tap-repress-timeout
            ht $hold-timeout
          )

          (defsrc
            grv     1       2       3       4       5       6       7       8       9       0       -       =       bspc
            tab     q       w       e       r       t       y       u       i       o       p       [       ]       \
            caps    a       s       d       f       g       h       j       k       l       ;       '       ret
            lsft    z       x       c       v       b       n       m       ,       .       /       rsft
            lctl    lmet    lalt                    spc                     ralt    rmet    rctl
          )

          (defalias
            caps             (tap-hold $tt $ht esc (layer-while-held nav))
            a                (tap-hold $tt $ht a lmet)
            s                (tap-hold $tt $ht s lalt)
            d                (tap-hold $tt $ht d lsft)
            f                (tap-hold $tt $ht f lctl)
            j                (tap-hold $tt $ht j lctl)
            k                (tap-hold $tt $ht k lsft)
            l                (tap-hold $tt $ht l lalt)
            ;                (tap-hold $tt $ht ; lmet)
            c                (tap-hold $tt $ht c ${mkUnicodeFork "ç" "Ç"})
            bslsh            (tap-hold $tt $ht \ ${mkUnicodeFork "ª" "º"})
            tab              (tap-hold $tt $ht tab (layer-while-held xf86keys))
            ralt             (layer-while-held session)
            enter-acute      (macro (unmod [) (sequence 500 hidden-delay-type) 10 nop0)
            enter-grave      (macro [ (sequence 750 hidden-delay-type) 10 nop1)
            enter-tilde      (macro (unmod ') (sequence 500 hidden-delay-type) 10 nop2)
            enter-circumflex (macro ' (sequence 750 hidden-delay-type) 10 nop3)
            lbkt             (fork @enter-acute @enter-grave (lsft rsft))
            apos             (fork @enter-tilde @enter-circumflex (lsft rsft))
          )

          (deflocalkeys-linux
            audfwd  208
            micmute 248
            audsrc  226
            audrwd  168
            audstp  166
            brtcyc  243
            brtdown 224
            brtup   225
            expl    144
            lnch1   148
            lnch2   149
            lnch3   202
            lnch4   203
            lncha   120
            lnchb   204
            pwoff   116
            lock    152
            sleep   142
            suspend 205
            tskpne  154
            term    151
            www     150
          )

          (deflocalkeys-win
            audsrc 181
            audstp 178
            expl   182
            sleep   95
            www    172
          )

          (deflayer base
            _       _       _       _       _       _       _       _       _       _       _       _       _       _
            @tab    _       _       _       _       _       _       _       _       _       _       @lbkt   _       @bslsh
            @caps   @a      @s      @d      @f      _       _       @j      @k      @l      @;      @apos   _
            _       _       _       @c      _       _       _       _       _       _       _       _
            _       _       _                       _                       @ralt   _       _
          )

          ;; ==================== Nav Layer (Hold Caps Lock) ====================
          (deflayer nav
            _       _       _       _       _       _       _       _       _       _       _       _       _       _
            _       _       home    end     _       _       _       _       0       S-4     _       _       _       _
            _       _       _       _       _       _       left    down    up      right   _       _       _
            _       _       _       _       bspc    del     ret     _       pgup    pgdn    _       _
            _       _       _                       _                       _       _       _
          )

          ;; ==================== XF86Keys Layer (Hold Tab) =====================
          ;; --------------------------------------
          ;; Keys that kanata does support natively
          ;;
          ;; f14     | XF86Launch5          |  KEY_F14          (184) keycode 192 (keysym 0x1008ff45) | 125 VK_F14                 (0x7D)
          ;; f15     | XF86Launch6          |  KEY_F15          (185) keycode 193 (keysym 0x1008ff46) | 126 VK_F15                 (0x7E)
          ;; f16     | XF86Launch7          |  KEY_F16          (186) keycode 194 (keysym 0x1008ff47) | 127 VK_F16                 (0x7F)
          ;; f17     | XF86Launch8          |  KEY_F17          (187) keycode 195 (keysym 0x1008ff48) | 128 VK_F17                 (0x80)
          ;; f18     | XF86Launch9          |  KEY_F18          (188) keycode 196 (keysym 0x1008ff49) | 129 VK_F18                 (0x81)
          ;;
          ;; prev    | XF86AudioPrev        |  KEY_PREVIOUSSONG (165) keycode 173 (keysym 0x1008ff16) | 177 VK_MEDIA_PREV_TRACK    (0xB1)
          ;; pp      | XF86AudioPlay        |  KEY_PLAYPAUSE    (164) keycode 172 (keysym 0x1008ff14) | 179 VK_MEDIA_PLAY_PAUSE    (0xB3)
          ;; next    | XF86AudioNext        |  KEY_NEXTSONG     (163) keycode 171 (keysym 0x1008ff17) | 176 VK_MEDIA_NEXT_TRACK    (0xB0)
          ;; mute    | XF86AudioMute        |  KEY_MUTE         (113) keycode 121 (keysym 0x1008ff12) | 173 VK_VOLUME_MUTE         (0xAD)
          ;; vold    | XF86AudioLowerVolume |  KEY_VOLUMEDOWN   (114) keycode 122 (keysym 0x1008ff11) | 174 VK_VOLUME_DOWN         (0xAE)
          ;; volu    | XF86AudioRaiseVolume |  KEY_VOLUMEUP     (115) keycode 123 (keysym 0x1008ff13) | 175 VK_VOLUME_UP           (0xAF)
          ;;
          ;; calc    | XF86Calculator       |  KEY_CALC         (140) keycode 148 (keysym 0x1008ff1d) | 183 VK_LAUNCH_APP2         (0xB7)
          ;; prnt    | Print                |  KEY_SYSRQ        (099) keycode 107 (keysym 0xff61)     |  44 VK_SNAPSHOT            (0x2C)
          ;;
          ;; -------------------------------------------------------------
          ;; Keys that need mapping and are supported by linux and windows
          ;;
          ;; audsrc  | XF86AudioMedia       | KEY_MEDIA         (226) keycode 234 (keysym 0x1008ff32) | 181 VK_LAUNCH_MEDIA_SELECT (0xB5)
          ;; audstp  | XF86AudioStop        | KEY_STOPCD        (166) keycode 174 (keysym 0x1008ff15) | 178 VK_MEDIA_STOP          (0xB2)
          ;; expl    | XF86Explorer         | kEY_FILE          (144) keycode 152 (keysym 0x1008ff5d) | 182 VK_LAUNCH_APP1         (0xB6)
          ;; www     | XF86WWW              | KEY_WWW           (150) keycode 158 (keysym 0x1008ff2e) | 172 VK_BROWSER_HOME        (0xAC)
          ;;
          ;; ------------------------------------------------------
          ;; Keys that need mapping and are supported only by linux
          ;;
          ;; lnch1   | XF86Launch1            | KEY_PROG1            (148) keycode 156 (keysym 0x1008ff41)
          ;; lnch2   | XF86Launch2            | KEY_PROG2            (149) keycode 157 (keysym 0x1008ff42)
          ;; lnch3   | XF86Launch3            | KEY_PROG3            (202) keycode 210 (keysym 0x1008ff43)
          ;; lnch4   | XF86Launch4            | KEY_PROG4            (203) keycode 211 (keysym 0x1008ff44)
          ;; lncha   | XF86LaunchA            | KEY_SCALE            (120) keycode 128 (keysym 0x1008ff4a)
          ;; lnchb   | XF86LaunchB            | KEY_DASHBOARD        (204) keycode 212 (keysym 0x1008ff4b)
          ;;
          ;; audrwd  | XF86AudioRewind        | KEY_REWIND           (168) keycode 176 (keysym 0x1008ff3e)
          ;; audfwd  | XF86AudioForward       | KEY_FASTFORWARD      (208) keycode 216 (keysym 0x1008ff97)
          ;; micmute | XF86AudioMicMute       | KEY_MICMUTE          (248) keycode 198 (keysym 0x1008ffb2)
          ;;         |
          ;; brtcyc  | XF86MonBrightnessCycle | KEY_BRIGHTNESS_CYCLE (243) keycode 251 (keysym 0x1008ff07)
          ;; brtdown | XF86MonBrightnessDown  | KEY_BRIGHTNESSDOWN   (224) keycode 232 (keysym 0x1008ff03)
          ;; brtup   | XF86MonBrightnessUp    | KEY_BRIGHTNESSUP     (225) keycode 233 (keysym 0x1008ff02)
          ;;
          ;; www     | XF86WWW                | KEY_WWW              (150) keycode 158 (keysym 0x1008ff2e)
          ;; expl    | XF86Explorer           | KEY_FILE             (144) keycode 152 (keysym 0x1008ff5d)
          ;; term    | XF86DOS                | KEY_MSDOS            (151) keycode 159 (keysym 0x1008ff5a)
          ;; tskpne  | XF86TaskPane           | KEY_CYCLEWINDOWS     (154) keycode 162 (keysym 0x1008ff7f)
          ;;
          (platform (linux)
            (deflayer xf86keys
              _       lnch1   lnch2   lnch3   lnch4   f14     f15     f16     f17     f18     _       _       _       _
              _       _       www     expl    _       term    tskpne  _       audrwd  audfwd  prnt    brtdown brtup   brtcyc
              _       lncha   _       _       _       _       _       prev    pp      next    audstp  _       _
              _       _       _       calc    _       lnchb   micmute mute    vold    volu    audsrc  _
              _       _       _                       _               _       _       _
            )
          )

          (platform (win winiov2 wintercept)
            (deflayer xf86keys
              _       _       _       _       _       f14     f15     f16     f17     f18     _       _       _       _
              _       _       www     expl    _       _       _       _       _       _       prnt    _       _       _
              _       _       _       _       _       _       _       prev    pp      next    audstp  _       _
              _       _       _       calc    _       _       _       mute    vold    volu    audsrc  _
              _       _       _                       _               _       _       _
            )
          )

          ;; ==================== Session Layer (Hold Right Alt) ====================
          ;;
          ;; lock    | XF86ScreenSaver | KEY_SCREENLOCK (152) | keycode 160 (keysym 0x1008ff2d) |
          ;; pwoff   | XF86PowerOff    | KEY_POWER      (116) | keycode 124 (keysym 0x1008ff14) |
          ;; sleep   | XF86Sleep       | KEY_SLEEP      (142) | keycode 150 (keysym 0x1008ff2f) | 95 VK_SLEEP (0x5F)
          ;; suspend | XF86Suspend     | KEY_SUSPEND    (205) | keycode 213 (keysym 0x1008ffa7) |
          ;; _       | XF86LogOff      | KEY_LOGOFF ??? (433) | THERE IS NO XF86LogOff KEY!     |
          ;; _       | XF86Hibernate   | ?????????            | THERE IS NO XF86Hibernate KEY!  |
          ;;
          (platform (linux)
            (deflayer session
              _       _       _       _       _       _       _       _       _       _       _         _       _       _
              _       _       _       _       _       _       _       _       _       _       pwoff     _       _       _
              _       _       suspend _       _       _       _       _       _       lock    _         _       _
              _       _       _       _       _       _       _       _       _       _       _         _
              _       _       _                       _                       _       _       _
            )
          )

          (platform (win winiov2 wintercept)
            (deflayer session
              _       _       _       _       _       _       _       _       _       _       _         _       _       _
              _       _       _       _       _       _       _       _       _       _       _         _       _       _
              _       _       sleep   _       _       _       _       _       _       M-l     _         _       _
              _       _       _       _       _       _       _       _       _       _       _         _
              _       _       _                       _                       _       _       _
            )
          )

          ;; ==================== Dead Key Virtual Keys ====================
          (defvirtualkeys
            acute-A    (macro bspc (unicode Á))
            acute-E    (macro bspc (unicode É))
            acute-I    (macro bspc (unicode Í))
            acute-O    (macro bspc (unicode Ó))
            acute-U    (macro bspc (unicode Ú))
            acute-a    (macro bspc (unicode á))
            acute-e    (macro bspc (unicode é))
            acute-i    (macro bspc (unicode í))
            acute-o    (macro bspc (unicode ó))
            acute-u    (macro bspc (unicode ú))
            acute-spc  (macro bspc (unicode ´))

            grave-A    (macro bspc (unicode À))
            grave-E    (macro bspc (unicode È))
            grave-I    (macro bspc (unicode Ì))
            grave-O    (macro bspc (unicode Ò))
            grave-U    (macro bspc (unicode Ù))
            grave-a    (fork (macro bspc (unicode à)) (macro bspc (unicode À)) (lsft rsft))
            grave-e    (fork (macro bspc (unicode è)) (macro bspc (unicode È)) (lsft rsft))
            grave-i    (fork (macro bspc (unicode ì)) (macro bspc (unicode Ì)) (lsft rsft))
            grave-o    (fork (macro bspc (unicode ò)) (macro bspc (unicode Ò)) (lsft rsft))
            grave-u    (fork (macro bspc (unicode ù)) (macro bspc (unicode Ù)) (lsft rsft))
            grave-spc  (macro bspc (unicode `))

            tilde-A    (macro bspc (unicode Ã))
            tilde-O    (macro bspc (unicode Õ))
            tilde-a    (macro bspc (unicode ã))
            tilde-o    (macro bspc (unicode õ))
            tilde-spc  (macro bspc (unicode ~))

            circ-A    (macro bspc (unicode Â))
            circ-E    (macro bspc (unicode Ê))
            circ-I    (macro bspc (unicode Î))
            circ-O    (macro bspc (unicode Ô))
            circ-U    (macro bspc (unicode Û))
            circ-a    (fork (macro bspc (unicode â)) (macro bspc (unicode Â)) (lsft rsft))
            circ-e    (fork (macro bspc (unicode ê)) (macro bspc (unicode Ê)) (lsft rsft))
            circ-i    (fork (macro bspc (unicode î)) (macro bspc (unicode Î)) (lsft rsft))
            circ-o    (fork (macro bspc (unicode ô)) (macro bspc (unicode Ô)) (lsft rsft))
            circ-u    (fork (macro bspc (unicode û)) (macro bspc (unicode Û)) (lsft rsft))
            circ-spc  (macro bspc (unicode ^))
          )

          ;; ==================== Dead Key Sequences ====================
          ;; nop0 = acute ([), nop1 = grave (shift+[), nop2 = tilde ('), nop3 = circumflex (shift+')
          (defseq acute-A    (nop0 S-a))
          (defseq acute-E    (nop0 S-e))
          (defseq acute-I    (nop0 S-i))
          (defseq acute-O    (nop0 S-o))
          (defseq acute-U    (nop0 S-u))
          (defseq acute-a    (nop0 a))
          (defseq acute-e    (nop0 e))
          (defseq acute-i    (nop0 i))
          (defseq acute-o    (nop0 o))
          (defseq acute-u    (nop0 u))
          (defseq acute-spc  (nop0 spc))

          (defseq grave-A    (nop1 S-a))
          (defseq grave-E    (nop1 S-e))
          (defseq grave-I    (nop1 S-i))
          (defseq grave-O    (nop1 S-o))
          (defseq grave-U    (nop1 S-u))
          (defseq grave-a    (nop1 a))
          (defseq grave-e    (nop1 e))
          (defseq grave-i    (nop1 i))
          (defseq grave-o    (nop1 o))
          (defseq grave-u    (nop1 u))
          (defseq grave-spc  (nop1 spc))

          (defseq tilde-A    (nop2 S-a))
          (defseq tilde-O    (nop2 S-o))
          (defseq tilde-a    (nop2 a))
          (defseq tilde-o    (nop2 o))
          (defseq tilde-spc  (nop2 spc))

          (defseq circ-A    (nop3 S-a))
          (defseq circ-E    (nop3 S-e))
          (defseq circ-I    (nop3 S-i))
          (defseq circ-O    (nop3 S-o))
          (defseq circ-U    (nop3 S-u))
          (defseq circ-a    (nop3 a))
          (defseq circ-e    (nop3 e))
          (defseq circ-i    (nop3 i))
          (defseq circ-o    (nop3 o))
          (defseq circ-u    (nop3 u))
          (defseq circ-spc  (nop3 spc))
        '';
      };
    };
  };
}
