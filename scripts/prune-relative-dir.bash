#! /usr/bin/env bash

set -o nounset            # Fail on use of unset variable.
set -o errexit            # Exit on command failure.
set -o pipefail           # Exit on failure of any command in a pipeline.
set -o errtrace           # Trap errors in functions and subshells.
shopt -s inherit_errexit  # Inherit the errexit option status in subshells.

this_script_dir="$(cd "$(dirname "$0")" && pwd)"
. "$this_script_dir/utils/utils.bash" # Source utils


trace() {
  (( ! "$debug" )) || info "$@"
}

run_checks() {
  local target_dir="$1"
  local base_dir="$2"

  ! mount_exists_on_target "$target_dir" || #                                                           Error if mount already exists at target directory path
    fail "A mount already exists at target directory '$target_dir'"

  [ -d "$base_dir" ] || #                                                                               Error if base directory path is not a valid directrory
    fail "Base directory '$base_dir' is not a valid directory path or does not exist"

  [ ! -e "$target_dir" ] || [ -d "$target_dir" ] || #                                                   Error if target directory path exists and is not a directrory
    fail "Path marked to be the target directory '$target_dir' exists but it is not a directory"

  [ ! -d "$target_dir" ] || [ -z "$(ls --almost-all "$target_dir" 2> /dev/null)" ] || #                 Error if target directory exists and is not empty
    fail "Target directory '$target_dir' is not empty"

  has_relative_path "$base_dir" "$target_dir" || #                                                      Error if target directory is not a subpath of base directory
    fail "Target directory is not a subdirectory of base directory
  . base_dir:   '$base_dir'
  . target_dir: '$target_dir'"
}

prune_relative_dirs() {

  delete_empty_dirs_up_to_base() {
    local dir="$1"

    while [ "$dir" != "$base_dir" ] && [ -d "$dir" ] && [ -z "$(ls --almost-all "$dir" 2> /dev/null)" ]; do
      trace "Removing empty directory '%s'\n" "$dir"
      rmdir "$dir" || trace "Could not delete empty directory '$dir'"
      dir="$(dirname "$dir")"
    done
  }

  local target_dir="$1"
  local base_dir="$2"
  delete_empty_dirs_up_to_base "$target_dir"
}

main() {
  # Print a useful trace when an error occurs
  trap 'fail $? \"Error when executing ${BASH_COMMAND} at line ${LINENO}!\"' ERR

  # Get inputs from command line arguments
  if [[ "$#" -lt 2 ]] || [[ "$#" -gt 3 ]]; then
    fail "Error: 'prune-relative-dir.bash' requires at least *two* and at most *three* args."
  fi

  target_dir="$(canonicalize_path "$1")"
  base_dir="$(canonicalize_path "$2")"
  debug="${3-0}"

  (( ! "$debug" )) || set -o xtrace

  run_checks "$target_dir" "$base_dir"
  prune_relative_dirs "$target_dir" "$base_dir"
}

main "$@"
