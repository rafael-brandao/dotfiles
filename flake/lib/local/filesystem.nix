{lib, ...}: let
  inherit
    (builtins)
    attrNames
    filter
    pathExists
    readDir
    ;
  inherit
    (lib)
    filterAttrs
    flipPipe
    pathType
    pipe
    mapCartesianProduct
    ;
in rec {
  /**
  Check whether a given path exists and is a regular file.

  # Inputs

  `path`

  : A path (string or path type) to check on the filesystem.

  # Type

  ```
  isFile :: Path -> Bool
  ```

  # Description

  Returns `true` if the given `path` exists and is of type `"regular"`, indicating a plain file.
  This excludes directories, symlinks, or other special types.

  # Examples
  :::{.example}
  ## `isFile` usage example

  ```nix
  isFile ./example.nix
  => true  # if the file exists and is a regular file
  ```
  :::
  */
  isFile = path: pathExists path && pathType path == "regular";

  /**
  Return a list of existing `configuration.nix` files by checking all combinations
  of base directories and directory names.

  # Inputs

  `baseDirs`

  : A list of base directory paths.

  `dirNames`

  : A list of subdirectory names under each base directory.

  # Type

  ```
  crossValidConfigurationPaths :: {
    baseDirs :: [String],
    dirNames :: [String]
  } -> [String]
  ```

  # Description

  This function computes the Cartesian product of `baseDirs` and `dirNames`, treating
  each pair as a potential configuration path of the form:

  ```
  <baseDir>/<dirName>/configuration.nix
  ```

  It then filters the resulting list to include only those paths that exist and are regular files.

  Internally, it uses `lib.mapCartesianProduct` to generate all combinations,
  and `isFile` to filter valid paths.

  # Examples
  :::{.example}
  ## `crossValidConfigurationPaths` usage example

  ```nix
  crossValidConfigurationPaths {
    baseDirs = [ "/etc/nixos" "/home/user/configs" ];
    dirNames = [ "host1" "host2" ];
  }
  =>
  [
    "/etc/nixos/host1/configuration.nix"
    "/home/user/configs/host2/configuration.nix"
  ]  # assuming these files exist and are regular files
  ```
  :::
  */
  crossValidConfigurationPaths = {
    baseDirs,
    dirNames,
  }: let
    mkPossibleConfigurationPath = {
      a,
      b,
    }: let
      baseDir = a;
      dirName = b;
    in
      baseDir + "/${dirName}/configuration.nix";
  in
    pipe {
      a = baseDirs;
      b = dirNames;
    } [
      (mapCartesianProduct mkPossibleConfigurationPath)
      (filter isFile)
    ];

  /**
  Return a list of full paths to regular files in the specified directory.

  # Inputs
  `dir`
  : A `Path` or `String` representing an absolute directory path to scan for regular files.

  # Type
  ```
  listRegularFilesIn :: Path | String -> [String]
  ```

  # Description
  This function reads the contents of the specified directory and returns a list of full paths to all
  regular files (not directories or symlinks) within it. It uses `builtins.readDir` to retrieve directory
  contents, filters for regular files using `filterAttrs`, and constructs full file paths using
  `toFullPaths`.

  # Examples
  :::{.example}
  ## `listRegularFilesIn` usage example
  ```nix
  listRegularFilesIn "/etc/nixos"
  =>
  [
    "/etc/nixos/configuration.nix"
    "/etc/nixos/hardware-configuration.nix"
  ] # assuming these are regular files in the directory
  ```
  :::
  */
  listRegularFilesIn = dir: let
    filterRegularFiles = filterAttrs (_name: value: value == "regular");
    toFullPaths = flipPipe [
      attrNames
      (map (file: dir + "/${file}"))
    ];
  in
    pipe dir [
      readDir
      filterRegularFiles
      toFullPaths
    ];
}
