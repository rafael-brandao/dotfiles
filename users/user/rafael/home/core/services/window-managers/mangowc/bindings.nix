{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.wayland.windowManager.mango;
  inherit (config.rb) defaults;

  normalizeKeyBinding = kb:
    if !hasInfix "," kb
    then "none,${kb}"
    else kb;

  # Process app bindings
  appBindings = let
    terminalLauncher =
      defaults.apps.terminalLauncher or {
        enable = false;
      };

    resolveCmd = app:
      if app.isTui && terminalLauncher.enable
      then "${terminalLauncher.finalCommand} ${app.finalCommand}"
      else app.finalCommand;

    mkAppBinding = _name: app:
      map
      (kb: "${normalizeKeyBinding kb},spawn,${resolveCmd app}")
      app.keyBindings;
  in
    pipe defaults.apps [
      (filterAttrs (_name: app:
        app.enable
        && app.keyBindings != []))
      (mapAttrsToList mkAppBinding)
      flatten
    ];

  # Process core bindings
  coreBindings = let
    mkCoreBinding = _name: cmd: let
      action =
        if cmd.requireShell
        then "spawn_shell"
        else "spawn";
    in
      map
      (kb: "${normalizeKeyBinding kb},${action},${cmd.command}")
      cmd.keyBindings;

    mkGroupBindings = _group:
      flipPipe [
        (filterAttrs (_name: cmd:
          cmd.enable
          && cmd.keyBindings != []))
        (mapAttrsToList mkCoreBinding)
        flatten
      ];
  in
    pipe defaults.core [
      (mapAttrsToList mkGroupBindings)
      flatten
    ];

  bind = let
    defaultLauncherBindings = appBindings ++ coreBindings;

    staticBindings = [
      # reload config
      "Super+Shift,r,reload_config"

      # exit
      "Super+Shift,q,quit"
      "Alt,q,killclient"

      # switch window focus
      "Super,space,focusstack,next"
      "Super,semicolon,focuslast"

      # === WINDOW FOCUS DIRECTION (Vim-style h j k l) ===
      "Alt,h,focusdir,left"
      "Alt,l,focusdir,right"
      "Alt,k,focusdir,up"
      "Alt,j,focusdir,down"

      # === SWAP WINDOW (Vim-style) ===
      "Alt+Shift,h,exchange_client,left"
      "Alt+Shift,l,exchange_client,right"
      "Alt+Shift,k,exchange_client,up"
      "Alt+Shift,j,exchange_client,down"

      # === MOVE WINDOW (Vim-style) ===
      "Ctrl+Shift,h,movewin,-50,+0"
      "Ctrl+Shift,l,movewin,+50,+0"
      "Ctrl+Shift,k,movewin,+0,-50"
      "Ctrl+Shift,j,movewin,+0,+50"

      # === RESIZE WINDOW (Vim-style) ===
      "Ctrl+Alt,h,resizewin,-50,+0"
      "Ctrl+Alt,l,resizewin,+50,+0"
      "Ctrl+Alt,k,resizewin,+0,-50"
      "Ctrl+Alt,j,resizewin,+0,+50"

      # switch window status
      "Super,g,toggleglobal,"
      "Alt,tab,toggleoverview,"
      "Alt,backslash,togglefloating,"
      "Alt,a,togglemaximizescreen,"
      "Alt,f,togglefullscreen,"
      "Alt+Shift,f,togglefakefullscreen,"
      "Super,i,minimized,"
      "Super+Shift,i,restore_minimized"
      "Super,o,toggleoverlay,"
      "Alt,z,toggle_scratchpad"

      # scroller layout
      "Alt,e,set_proportion,1.0"
      "Alt,x,switch_proportion_preset,"

      # tile layout
      "Super,r,incnmaster,1"
      "Super,t,incnmaster,-1"
      "Alt,s,zoom,"

      # switch layout
      "Super+Ctrl,i,setlayout,tile"
      "Super+Ctrl,l,setlayout,scroller"
      "Super+Ctrl,space,switch_layout"

      # === VIEW (Workspace Switch)
      #
      # Toggle view
      "Super,1,view,1,0"
      "Super,2,view,2,0"
      "Super,3,view,3,0"
      "Super,4,view,4,0"
      "Super,5,view,5,0"
      "Super,6,view,6,0"
      "Super,7,view,7,0"
      "Super,8,view,8,0"
      "Super,9,view,9,0"

      # Send window to tag
      "Alt,1,tag,1,0"
      "Alt,2,tag,2,0"
      "Alt,3,tag,3,0"
      "Alt,4,tag,4,0"
      "Alt,5,tag,5,0"
      "Alt,6,tag,6,0"
      "Alt,7,tag,7,0"
      "Alt,8,tag,8,0"
      "Alt,9,tag,9,0"

      # Toggle tag on window
      "Super+Alt,1,toggletag,1"
      "Super+Alt,2,toggletag,2"
      "Super+Alt,3,toggletag,3"
      "Super+Alt,4,toggletag,4"
      "Super+Alt,5,toggletag,5"
      "Super+Alt,6,toggletag,6"
      "Super+Alt,7,toggletag,7"
      "Super+Alt,8,toggletag,8"
      "Super+Alt,9,toggletag,9"

      # Toggle view (multi-tag)
      "Super+Ctrl,1,toggleview,1"
      "Super+Ctrl,2,toggleview,2"
      "Super+Ctrl,3,toggleview,3"
      "Super+Ctrl,4,toggleview,4"
      "Super+Ctrl,5,toggleview,5"
      "Super+Ctrl,6,toggleview,6"
      "Super+Ctrl,7,toggleview,7"
      "Super+Ctrl,8,toggleview,8"
      "Super+Ctrl,9,toggleview,9"

      # === MONITOR / WORKSPACE NAVIGATION ===
      #
      # Super + , . [ ]  → Switch current view/workspace to adjacent monitor (Qtile style)
      "Super,comma,viewtoleft,0"
      "Super,period,viewtoright,0"

      # Smart workspace switching + move window to adjacent tag
      "Ctrl,comma,viewtoleft_have_client,0"
      "Ctrl,period,viewtoright_have_client,0"

      "Super+Ctrl,comma,tagtoleft,0"
      "Super+Ctrl,period,tagtoright,0"

      # Alt + , . [ ]    → Focus adjacent monitor (Qtile style)
      "Alt,comma,focusmon,left"
      "Alt,period,focusmon,right"
      "Alt,bracketleft,focusmon,down"
      "Alt,bracketright,focusmon,up"

      # Super + Alt + , . [ ]    → Tag adjacent monitor
      "Super+Alt,comma,tagmon,left"
      "Super+Alt,period,tagmon,right"
      "Super+Alt,bracketleft,tagmon,down"
      "Super+Alt,bracketright,tagmon,up"

      # === GAPS ===
      "Alt+Shift,x,incgaps,1"
      "Alt+Shift,z,incgaps,-1"
      "Alt+Shift,r,togglegaps"
    ];
  in
    defaultLauncherBindings ++ staticBindings;

  mousebind = [
    "Super,btn_left,moveresize,curmove"
    "Super,btn_right,moveresize,curresize"
    "Alt,btn_middle,set_proportion,0.5"
    "Super+Ctrl,btn_left,minimized"
    "Super+Ctrl,btn_right,killclient"
    "Super+Ctrl,btn_middle,togglefullscreen"
    "none,btn_middle,togglemaximizescreen,0"
  ];

  axisbind = [
    "Super,up,viewtoleft_have_client"
    "Super,down,viewtoright_have_client"
    "Alt,up,focusdir,left"
    "Alt,down,focusdir,right"
    "Super+Shift,up,exchange_client,left"
    "Super+Shift,down,exchange_client,right"
  ];

  gesturebind = [
    "none,left,3,focusdir,left"
    "none,right,3,focusdir,right"
    "none,up,3,focusdir,up"
    "none,down,3,focusdir,down"
    "none,left,4,viewtoleft_have_client"
    "none,right,4,viewtoright_have_client"
    "none,up,4,toggleoverview,1"
    "none,down,4,toggleoverview,1"
  ];
in
  mkIf cfg.enable {
    wayland.windowManager.mango.settings = {
      inherit
        bind
        mousebind
        axisbind
        gesturebind
        ;
    };

    rb.defaults = {
      apps = {
        launcher = {keyBindings = ["Alt,space"];};
        editor = {keyBindings = ["Super,e"];};
        fileManager = {keyBindings = ["Super,f"];};
        screenshotTool = {keyBindings = ["Ctrl+Shift,s"];};
        systemMonitor = {keyBindings = ["Ctrl+Shift,m"];};
        terminal = {keyBindings = ["Alt,return"];};
        webBrowser = {keyBindings = ["Super,b"];};
      };
      core = {
        session = {
          lock = {keyBindings = ["Super,l"];};
        };
        shell = {
          toggleBar = {keyBindings = ["Super,h"];};
          toggleNotifications = {keyBindings = ["Super,n"];};
          togglePowerMenu = {keyBindings = ["Super+Shift,escape"];};
        };
      };
    };
  }
