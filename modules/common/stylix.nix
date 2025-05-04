{
  config,
  inputs,
  lib,
  ...
}:
with lib; let
  cfg = config.stylix;

  findThemePath = let
    toYamlPaths = themeName:
      forEach cfg.themeSources (themesDir: [
        "${themesDir}/${themeName}.yaml"
        "${themesDir}/${themeName}.yml"
      ]);
  in
    flipPipe [
      toYamlPaths
      flatten
      (findFirst pathExists)
    ];
in {
  options.stylix = {
    themeSources = mkOption {
      type = with types; listOf path;
      default = ["${inputs.tt-schemes}/base16"];
      description = ''
        A list of directory paths that contain themes in the yaml format
      '';
    };
    theme = {
      name = mkOption {
        type = with types; nullOr str;
        default = null;
        description = ''
          The name of the theme to be searched in the `themeSources` directory list.
          Either this or the `path` option must be set.
        '';
      };
      path = mkOption {
        type = with types; nullOr path;
        default = null;
        description = ''
          A path to a base16 yaml theme. Takes precedence over the `name` option.
          Either this or the `name` option must be set.
        '';
      };
    };
  };

  config = mkIf (cfg.enable && (cfg.theme.name != null || cfg.theme.path != null)) (
    let
      configPath =
        if (cfg.theme.path != null)
        then cfg.theme.path
        else (findThemePath cfg.theme.name);
      generatedScheme = config.lib.yaml2nix configPath;
    in {
      stylix = {
        base16Scheme = mapAttrs (_name: value: lib.mkDefault value) generatedScheme.palette;
        polarity = mkIf (isString (generatedScheme.variant ? null)) (mkDefault generatedScheme.variant);
      };
    }
  );
}
