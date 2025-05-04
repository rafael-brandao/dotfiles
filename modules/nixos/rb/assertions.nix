{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.local.assertions;

  checkProxySensitiveUrls = let
    configOptionsToCheck = let
      getOptionsFrom = flipPipe [
        attrNames
        (subtractLists ["noProxy"])
        (map (attrName: {"networking.proxy.${attrName}" = config.networking.proxy.${attrName};}))
        (foldl' mergeAttrs {})
      ];
    in
      getOptionsFrom config.networking.proxy;

    filterSensitiveUrlsFrom = let
      matchFn = _name:
        allMatch [
          isString
          (flipPipe [(builtins.match "^https?://([^:]+)(:[^@]+)?@[^:]+:[123456789][0123456789]*$") isNotNullOrEmpty])
        ];
    in
      filterAttrs matchFn;

    mkInvalidMessageFor = let
      mkMessageFromInvalidOption = proxyConfigOption: "  . config option `${proxyConfigOption}` might leak sensitive content in nix store";
      mapFn =
        flip foldlAttrs []
        (acc: proxyConfigOption: _:
          acc ++ [(mkMessageFromInvalidOption proxyConfigOption)]);
      reduceFn = mkString {
        start = "checkProxySensitiveUrls:\n";
        sep = "\n";
      };
    in
      flipPipe [mapFn reduceFn];

    message = let
      invalidProxyConfigOptions = filterSensitiveUrlsFrom configOptionsToCheck;
    in
      if (isEmpty invalidProxyConfigOptions)
      then ""
      else mkInvalidMessageFor invalidProxyConfigOptions;
  in {
    result = {
      inherit message;
      assertion = isEmptyString message;
    };
  };
in {
  options.local.assertions = {
    checkProxySensitiveUrls =
      mkEnableOption "check wheter a proxy url contains sensitive content like username and password"
      // {
        default = true;
      };
  };

  config.assertions = mkMerge [
    (mkIf cfg.checkProxySensitiveUrls [checkProxySensitiveUrls.result])
  ];
}
