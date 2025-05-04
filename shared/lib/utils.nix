{
  lib,
  pkgs,
  ...
}:
with lib; {
  config.lib.utils = rec {
    mkRecursiveDefault = value: let
      t = typeOf value;
    in
      if t == "set"
      then mapAttrs (_name: mkRecursiveDefault) value
      else if t == "list"
      then value
      else mkDefault value;

    mkWarnings = with lib;
      flip foldl' [] (
        acc: attr:
          if !attr.assertion
          then acc ++ [attr.message]
          else acc
      );

    # very generic simple function to convert yaml no nix attrset
    yaml2nix = let
      yaml2json = path:
        pkgs.runCommand "yaml-to-json" {} ''
          # shellcheck disable=SC2086,SC2154,SC2188
          ${pkgs.yq-go}/bin/yq --output-format=json '.' ${path} > $out
        '';
    in
      flipPipe [
        yaml2json
        readFile
        fromJSON
      ];
  };
}
