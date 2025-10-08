{
  lib,
  pkgs,
  ...
}:
with lib; let
  inherit
    (builtins)
    fromJSON
    ;
in {
  config.lib.utils = rec {
    identityFunction = x: x;

    mkWarnings = flip foldl' [] (
      acc: attr:
        if !attr.assertion
        then acc ++ [attr.message]
        else acc
    );

    toShellArray = {
      applyFn ? identityFunction,
      identLevel ? 2,
      inline ? false,
    }: let
      ident = strings.replicate identLevel " ";
      mapFn = map (item: "${ident}${applyFn item}");
      mkStringFn = mkString {
        start =
          if inline
          then "("
          else "(\n";
        sep =
          if inline
          then " "
          else "\n";
        end =
          if inline
          then ")"
          else "\n)";
      };
    in
      flipPipe [mapFn mkStringFn];

    fromYAML = let
      yaml2json = yamlFilePath:
        pkgs.runCommand "yaml-to-json" {} ''
          # shellcheck disable=SC2086,SC2154,SC2188
          ${pkgs.yq-go}/bin/yq --output-format=json '.' ${yamlFilePath} > $out
        '';
    in
      flipPipe [
        yaml2json
        readFile
        fromJSON
      ];
  };
}
