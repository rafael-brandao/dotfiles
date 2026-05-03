{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.wayland.windowManager.mango;

  stylixEnabled = attrByPath ["stylix" "enable"] false config;

  toMangoColor = color: "0x${color}ff";
in
  mkIf cfg.enable {
    xdg.configFile."mango/stylix/colors.conf" = mkIf stylixEnabled {
      text = with config.lib.stylix.colors; ''
        bordercolor = ${toMangoColor base03}
        focuscolor = ${toMangoColor base0D}
        globalcolor = ${toMangoColor base0E}
        maximizescreencolor = ${toMangoColor base09}
        overlaycolor = ${toMangoColor base0B}
        rootcolor = ${toMangoColor base00}
        scratchpadcolor = ${toMangoColor base0C}
        shadowscolor = ${toMangoColor base00}
        urgentcolor = ${toMangoColor base08}
      '';
    };

    wayland.windowManager.mango.settings = mkMerge [
      {
        bordercolor = "0x444444ff";
        focuscolor = "0xc9b890ff";
        globalcolor = "0x8d64cfff";
        maximizescreencolor = "0xda7510ff";
        overlaycolor = "0x89aa61ff";
        rootcolor = "0x201b14ff";
        scratchpadcolor = "0xc4939dff";
        shadowscolor = "0x000000ff";
        urgentcolor = "0xad401fff";
      }
      (mkIf stylixEnabled {
        source = "./stylix/colors.conf";
      })
    ];
  }
