{lib, ...}: let
  inherit
    (builtins)
    toString
    ;
  inherit
    (lib)
    getAttrFromPath
    flipPipe
    listToAttrs
    nameValuePair
    ;
in {
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
