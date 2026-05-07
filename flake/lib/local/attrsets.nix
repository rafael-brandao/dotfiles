{lib, ...}: let
  inherit
    (lib)
    attrNames
    concatMap
    flatten
    flipPipe
    getAttrFromPath
    isAttrs
    listToAttrs
    mapAttrsToList
    nameValuePair
    ;
in rec {
  /*
  Expands an attrset whose values are lists into a flat attrset, by mapping
  each key-list pair into a list of name/value pairs and merging the results.

  Type: expandAttrListToAttrs :: (string -> a -> [{ name :: string, value :: b }]) -> { string :: [a] } -> { string :: b }

  Example:
  expandAttrListToAttrs (name: map (alias: { name = alias; value = name; })) {
    banana = [ "yellow-fruit" "curved-fruit" ];
    apple  = [ "red-fruit" "round-fruit" ];
    grape  = [ "purple-fruit" ];
  }
  => {
    "yellow-fruit" = "banana";
    "curved-fruit" = "banana";
    "red-fruit"    = "apple";
    "round-fruit"  = "apple";
    "purple-fruit" = "grape";
  }
  */
  expandAttrListToAttrs = mapFn:
    flipPipe [
      (mapAttrsToList mapFn)
      flatten
      listToAttrs
    ];

  /*
  Recursively flattens a nested attrset into a list of arrays, where each
  array contains the path of keys leading to a leaf value, followed by the
  leaf value itself. The leaf value can be of any type.

  Type: flattenAttrPaths :: AttrSet -> [[ string | any ]]

  Example:
  flattenAttrPaths {
    a = {
      b = 1;
    };
    c = {
      d = {
        e = 2;
      };
    };
    f = 3;
  }
  => [
    [ "a" "b" 1 ]
    [ "c" "d" "e" 2 ]
    [ "f" 3 ]
  ]
  */
  flattenAttrPaths = attrs:
    if isAttrs attrs
    then
      concatMap (
        key:
          map (child: [key] ++ child) (flattenAttrPaths attrs.${key})
      ) (attrNames attrs)
    else [[attrs]];

  /*
  Indexes a list of atrrsets by an attribute path
  All attrsets in this list must have the attribute path to index

  Type: indexAttrListFromPath :: [ string ] -> [<sets>] -> { set }

  Example:
  indexAttrListFromPath [ "meta" "name" ] [
    (rec { meta.name = "${username}@${hostname}"; username = "john"; hostname = "machine-01"; })
    (rec { meta.name = "${username}@${hostname}"; username = "jane"; hostname = "machine-01"; })
  ]
  => {
    "john@machine-01" = { meta.name = "john@$machine-01"; username = "john"; hostname = "machine-01"; };
    "jane@machine-01" = { meta.name = "jane@$machine-01"; username = "jane"; hostname = "machine-01"; };
  }
  */
  indexAttrListFromPath = attrPath: let
    indexFn = set: nameValuePair (toString (getAttrFromPath attrPath set)) set;
  in
    flipPipe [(map indexFn) listToAttrs];
}
