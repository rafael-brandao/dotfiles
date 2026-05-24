{lib, ...}: let
  inherit
    (lib)
    all
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

  /*
  Chains multiple attrset predicate functions into a single predicate,
  returning true only when all predicates return true for the given
  name and value pair. Particularly useful in conjunction with filterAttrs
  to apply multiple independent filters over an attrset in a single pass,
  keeping each predicate focused and composable.

  Type: chainPredicateAttrs :: [ (string -> a -> bool) ] -> string -> a -> bool

  Example:
  chainPredicateAttrs [
    (name: value: value > 0)
    (name: value: value < 10)
  ] "a" 5
  => true

  chainPredicateAttrs [
    (name: value: value > 0)
    (name: value: value < 10)
  ] "a" 15
  => false

  Used with filterAttrs to chain 3 predicates over an attrset:
  filterAttrs (chainPredicateAttrs [
    (name: value: value.age >= 18)
    (name: value: value.score > 50)
    (name: value: name != "banned-user")
  ]) {
    alice   = { age = 25; score = 80; };
    bob     = { age = 15; score = 90; };
    charlie = { age = 30; score = 40; };
    dave    = { age = 22; score = 75; };
    eve     = { age = 19; score = 60; };
  }
  => {
    alice = { age = 25; score = 80; };
    dave  = { age = 22; score = 75; };
    eve   = { age = 19; score = 60; };
  }
  */
  chainPredicateAttrs = predicates: name: value: all (f: f name value) predicates;

  /*
  Negates an attrset predicate function, returning a new predicate that
  yields the opposite boolean result for any given name and value.

  Type: negatePredicateAttrs :: (string -> a -> bool) -> string -> a -> bool

  Example:
  negatePredicateAttrs (name: value: value > 2) "a" 3
  => false

  negatePredicateAttrs (name: value: value > 2) "a" 1
  => true
  */
  negatePredicateAttrs = predicate: name: value: !(predicate name value);
}
