{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit (builtins) map readDir;
  cfg = config.stylix;

  filterYamlFilesFn =
    pipe [".yaml" ".yml"] [(map hasSuffix) anyMatch];

  stripExtension = flipPipe [
    (splitString ".")
    init
    (concatStringsSep ".")
  ];

  listYamlFiles = dir:
    pipe dir [
      readDir
      (filterAttrs (_: fileType: fileType == "regular"))
      attrNames
      (filter filterYamlFilesFn)
      (map (fileName: {
        name = stripExtension fileName;
        value = dir + "/${fileName}";
      }))
      listToAttrs
    ];

  schemeMap = {
    base16-schemes = listYamlFiles (pkgs.base16-schemes + /share/themes);
  };

  isSchemePath = pipe schemeMap [(collect isString) (flip elem)];
in {
  options.stylix = {
    scheme = mkOption {
      type = with types; addCheck (nullOr path) (path: (path == null) || (isSchemePath path));
      default = null;
      description = "Type safe scheme to select from one of ${attrNames schemeMap} packages";
    };
  };
  config = {
    lib.stylix.schemes = schemeMap;

    stylix = let
      variant = pipe cfg.scheme [
        config.lib.utils.fromYAML
        (attrByPath ["variant"] null)
        (variant:
          if elem variant ["dark" "either" "light"]
          then variant
          else null)
      ];
    in
      mkIf cfg.enable {
        base16Scheme = mkIf (cfg.scheme != null) (mkDefault cfg.scheme);
        polarity = mkIf (cfg.scheme != null && variant != null) (mkDefault variant);
      };
  };
}
