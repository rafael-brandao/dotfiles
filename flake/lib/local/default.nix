{
  flakeArgs,
  lib,
}: let
  extended-lib = lib.makeExtensible (
    self: let
      callLibs = file:
        import file {
          inherit flakeArgs;
          lib = lib.extend (_previous: final: (self // final));
        };
    in {
      local = {
        attrsets = callLibs ./attrsets.nix;
        filesystem = callLibs ./filesystem.nix;
        project = callLibs ./project.nix;
        tagRules = callLibs ./tag-rules.nix;

        inherit
          (self.local.attrsets)
          chainPredicateAttrs
          expandAttrListToAttrs
          flattenAttrPaths
          indexAttrListFromPath
          negatePredicateAttrs
          ;
        inherit
          (self.local.filesystem)
          crossValidConfigurationPaths
          isFile
          listRegularFilesIn
          ;
        inherit
          (self.local.project)
          paths
          ;
      };
    }
  );
in
  lib.extend (_previous: final: final // extended-lib)
