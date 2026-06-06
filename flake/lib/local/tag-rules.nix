{lib, ...}:
with lib;
  hostcfg: {
    addRuntimePlatform = {
      description = ''
        Whether to add the host runtime platform to the final list of tags
      '';
      tags = [
        hostcfg.runtimePlatform
      ];
    };

    graphicalCapable = {
      description = ''
        Whether to add a `graphical` tag to the final list of tags if the host:
          (1) has tag `desktop` or `workstation`
              AND its runtimePlatform is one of:
                - `bare-metal`
                - `iso`
                - `virtual-machine`
          (2) OR its runtimePlatform `wsl`
      '';
      # hasAnyTagIn = searchTags: any (flip elem searchTags) config.tagsFinal;
      predicate = let
        pred1 = cfg: any (flip elem ["desktop" "workstation"]) cfg.tags;
        pred2 = cfg: elem cfg.runtimePlatform ["bare-metal" "iso" "virtual-machine"];
        pred3 = cfg: cfg.runtimePlatform == "wsl";

        _1 = allMatch [pred1 pred2];
        _2 = pred3;
      in
        anyMatch [_1 _2] hostcfg;
      tags = [
        "graphical"
      ];
    };

    desktopSessionCapable = {
      description = ''
        Hosts that can run a desktop environment or window manager (excluding WSL)
      '';
      predicate = with hostcfg;
        any (flip elem ["desktop" "workstation"]) tags
        && elem runtimePlatform ["bare-metal" "virtual-machine" "iso"];
      tags = [
        "desktop-session"
      ];
    };
  }
