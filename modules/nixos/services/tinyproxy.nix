{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.tinyproxy;

  settingsFormat = let
    mkValueStringTinyproxy = with lib;
      v:
        if typeOf v == "bool" && v
        then "yes"
        else if typeOf v == "bool" && !v
        then "no"
        else if types.path.check v
        then ''"${v}"''
        else generators.mkValueStringDefault {} v;

    mkKeyValueTinyproxy = {mkValueString ? mkValueStringDefault {}}: sep: k: v:
      if null == v
      then ""
      else "${lib.strings.escape [sep] k}${sep}${mkValueString v}";
  in
    pkgs.formats.keyValue {
      mkKeyValue = mkKeyValueTinyproxy {mkValueString = mkValueStringTinyproxy;} " ";
      listsAsDuplicateKeys = true;
    };

  mkConfigFile = name: settings:
    settingsFormat.generate "tinyproxy-${name}.conf" settings;

  defaultTinyproxyCfg = let
    splitLines = splitTrim "\n";
    removeComments = filter (s: !hasPrefix "#" s);
    tryString2Int = str: let
      matchInt = flipPipe [
        (builtins.match "^-?[123456789][0123456789]*$")
        isList
      ];
    in
      if (matchInt str)
      then toInt str
      else str;
    mapFn = map (line: let
      chunks = splitTrim " " line;
      key = head chunks;
      value = flipPipe [tail (concatStringsSep " ") tryString2Int] chunks;
    in {inherit key value;});
    foldFn = flip foldl' {} (
      acc: {
        key,
        value,
      }: let
        currentValue = attrByPath [key] null acc;
        newValue =
          if (currentValue == null)
          then value
          else if (isList currentValue)
          then currentValue ++ [value]
          else [currentValue] ++ [value];
      in
        acc
        // {
          "${key}" = newValue;
        }
    );
    applyFn = flipPipe [
      readFile
      builtins.unsafeDiscardStringContext
      splitLines
      removeComments
      mapFn
      foldFn
    ];
  in
    applyFn "${config.services.tinyproxy.package}/etc/tinyproxy/tinyproxy.conf";

  getSettingOr = name: defaultValue: let
    value = attrByPath ["settings" name] null cfg;
  in
    if (allMatch [isNotEmpty isList] value)
    then head value
    else if (allMatch [isNotEmpty isString] value)
    then value
    else defaultValue;

  user = getSettingOr "User" "tinyproxy";
  group = getSettingOr "Group" "tinyproxy";

  finalCfgDir = "/run/${user}";
  finalCfgFile = "${finalCfgDir}/tinyproxy.conf";

  generateFinalConfigFile = pkgs.writeShellScriptBin "generateFinalConfigFile" (
    let
      # user = config.systemd.services.tinyproxy.serviceConfig.User;
      # group = config.systemd.services.tinyproxy.serviceConfig.Group;
      cat = getExe' pkgs.coreutils "cat";
      echo = getExe' pkgs.coreutils "echo";
    in
      # shell
      ''
        echo "Concatenating final tinyproxy configuration in ${finalCfgFile}"
        # mkdir --parents "${finalCfgDir}"
        > "${finalCfgFile}" # create or clear the output file if it exists

        configPaths=(${lib.mkString {sep = " ";} cfg._includes})

        for configPath in "''${configPaths[@]}"; do
          if [[ -f "$configPath" ]]; then
            ${cat} "$configPath" >> "${finalCfgFile}"
          else
            ${echo} "Warning: $configPath does not exist or is not a file."
          fi
        done

        # chown --recursive ${user}:${group} "${finalCfgDir}"
        # chmod 0550 "${finalCfgDir}"
        chmod 0440 "${finalCfgFile}"
      ''
  );
in {
  options.services.tinyproxy = {
    includeDefaultCfg = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If set to `true`, includes the default configuration
        provided by the tinyproxy package. This takes precedence
        over all settings, so the default configuration can be
        overriden.
      '';
    };
    includes = mkOption {
      type = with types; listOf path;
      default = [];
      apply = map toString;
      description = ''
        A list of configuration files to be concatenated.
        Useful in case of configurations that have secrets
        and cannot or should not be put in the nix store.
      '';
    };
    _includes = mkOption {
      type = with types; listOf (either path str);
      default = [(mkConfigFile "default" cfg.settings)] ++ cfg.includes;
      apply = map toString;
      internal = true;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      systemd = {
        services.tinyproxy.serviceConfig = {
          ExecStartPre = getExe generateFinalConfigFile;
          ExecStart = mkForce "${getExe cfg.package} -d -c ${finalCfgFile}";
          User = mkForce user;
          Group = mkForce group;
        };
      };

      system.activationScripts.generateTinyproxyWorkingDirectory =
        # shell
        ''
          mkdir --parents "${finalCfgDir}"
          chown ${user}:${group} "${finalCfgDir}"
          chmod 0750 "${finalCfgDir}"
        '';
    }
    (mkIf cfg.includeDefaultCfg {
      services.tinyproxy.settings = mapAttrs (_name: mkOverride 500) defaultTinyproxyCfg;
    })
  ]);
}
