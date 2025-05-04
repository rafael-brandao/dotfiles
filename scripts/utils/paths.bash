#! /usr/bin/env bash

# shellcheck shell=bash

# Return early if this script was already sourced
[ -z "${__SHELL_UTIL_PATHS_SOURCED-}" ] || return 0
__SHELL_UTIL_PATHS_SOURCED=1



# canonicalize_path() - Convert a path to its canonical absolute form
#
# This function converts the given path to its canonical absolute form,
# resolving any relative components and handling missing directories.
# It uses the `realpath` command with the `--canonicalize-missing` option
# to ensure that the returned path is absolute and consistent.
#
# Arguments:
#   $1 - The path to be canonicalized.
#
# Behavior:
# - Resolves the input path to its absolute form.
# - Any relative components are resolved.
# - If the path includes non-existent directories, they are handled
#   as if they exist, without causing errors.
#
# Example usage:
# - $ canonicalize_path "./dir/subdir"
#   Output: "/current/working/directory/dir/subdir"
#
# - $ canonicalize_path "/home/user/../otherdir"
#   Output: "/home/otherdir"
#
# - $ canonicalize_path "non/existent/path"
#   Output: "/current/working/directory/non/existent/path"
canonicalize_path() {
  realpath --quiet --canonicalize-missing "$(eval printf '%s' "$1")"
}


# mount_exists_on_target() - Check if a mount exists on a target directory
#
# This function checks if there is a mount point on the given target
# directory. It uses the `mount` command and `grep` to find an entry
# matching the target directory.
#
# Arguments:
#   $1 - The target directory to check for an existing mount point.
#
# Example usage:
#   if mount_exists_on_target "/mnt/mydir"; then
#     echo "A mount already exists on /mnt/mydir"
#   else
#     echo "No mount found on /mnt/mydir"
#   fi
#
# Example output:
#   A mount already exists on /mnt/mydir
mount_exists_on_target() {
  mount | grep --extended-regexp "^.+ on $1 type .+\$" > /dev/null
}


# get_relative_path() - Calculate the relative path between two directories.
#
# This function determines which of the two provided directories is the parent
# and which is the child, based on their lengths. It then calculates and returns
# the relative path from the parent directory to the child directory.
#
# Arguments:
# 1. Path to the first directory.
# 2. Path to the second directory.
#
# Behavior:
# - If the two directories are identical, it returns an empty string.
# - If the child directory is not a child of the parent directory, it prints
#   an error message.
# - Otherwise, it returns the relative path from the parent to the child directory.
#
# Example usage:
# - $ get_relative_path /home/user/dir /home/user
#   Output: "dir"
#
# - $ get_relative_path ./dir /home/user/dir
#   Output: "/home/user/dir"
#
# - $ get_relative_path /home/user/dir /home/user/dir/subdir
#   Output: "subdir"
#
# - $ get_relative_path /home/user/dir /home/other/dir
#   Error: The directories '/home/user/dir' and '/home/other/dir' do not intersect.
#   (Returns exit code 1)
get_relative_path() {
  _relative_path_impls 'get_relative_path' "$@"
}


# has_relative_path() - Check if one directory is a child of another.
#
# This function determines which of the two provided directories is the parent
# and which is the child, based on their lengths. It then checks if the child
# directory is indeed a child of the parent directory.
#
# Arguments:
# 1. Path to the first directory.
# 2. Path to the second directory.
#
# Behavior:
# - Returns true (0) if the second directory is a child of the first directory.
# - Returns false (1) if the second directory is not a child of the first directory.
#
# Example usage:
# - $ has_relative_path /home/user/dir /home/user
#   Output: Returns 0 (true)
#
# - $ has_relative_path /home/user/dir /home/user/dir/subdir
#   Output: Returns 0 (true)
#
# - $ has_relative_path /home/user/dir /home/other/dir
#   Output: Returns 1 (false)
#
# - $ has_relative_path /home/user/dir /home/user
#   Output: Returns 1 (false)
has_relative_path() {
  _relative_path_impls 'has_relative_path' "$@"
}


#-------------------------------------------------------------------------------------------------
# Private Functions
#-------------------------------------------------------------------------------------------------

# _relative_path_impls()
#
# Private helper function to handle common logic for relative path
# determination and parent-child directory checks.
#
# This function encapsulates the logic needed for determining relative
# paths and checking parent-child directory relationships. It uses the
# `determine_parent_child` function to identify the parent and child
# directories, based on the length of the paths.
#
# Depending on the `func_name` argument, it calls either the
# `get_relative_path_impl` or `has_relative_path_impl` function to
# perform the necessary logic.
#
# It performs the following:
# 1. Ensures exactly two arguments are passed.
# 2. Uses `determine_parent_child` to identify parent and child dirs.
# 3. Calls the appropriate internal function based on `func_name`.
#
# Arguments:
#   $1 - Function name ('get_relative_path' or 'has_relative_path').
#   $2 - Path to the first directory.
#   $3 - Path to the second directory.
#
# Behavior:
# - Validates that exactly two directory paths are passed as arguments.
# - Determines parent and child directories.
# - Calls the appropriate internal function based on `func_name`.
#
# Example usage:
# - To call `get_relative_path_impl` with arguments:
#   _relative_path_impls 'get_relative_path' /home/user/dir /home/user
#
# - To call `has_relative_path_impl` with arguments:
#   _relative_path_impls 'has_relative_path' /home/user/dir /home/user/dir/subdir
_relative_path_impls() {

  get_relative_path_impl() {
    relative_path="${child_dir#"$parent_dir"}"

    # Check if the supposed parent_dir is not prefix of child_dir
    if [ "$relative_path" = "$child_dir" ]; then
      # If the comparison above is true, the directories are unrelated
      error "The directories '$parent_dir' and '$child_dir' do not intersect."
      return 1
    fi
    # If not, parent_dir is a prefix, so echo the calculated relative path
    echo "${relative_path#/}"
  }

  has_relative_path_impl() {
    test "${child_dir#"$parent_dir"}" != "$child_dir"
  }

  # Determine function name
  func_name="$1"
  shift

  # Ensure exactly two arguments were passed to the interface fucntion
  if [ "$#" -ne 2 ]; then
    error "Error: Function '$func_name' requires exactly two arguments."
    return 1
  fi

  # Canonicalize both arguments
  dir1="$(canonicalize_path "$1")"
  dir2="$(canonicalize_path "$2")"

  # Determine which directory is likely the parent based on string length
  if [ "${#dir1}" -le "${#dir2}" ]; then
    parent_dir="$dir1"
    child_dir="$dir2"
  else
    parent_dir="$dir2"
    child_dir="$dir1"
  fi

  # Invoke the specified function
  case "$func_name" in
    get_relative_path) get_relative_path_impl ;;
    has_relative_path) has_relative_path_impl ;;
    *) error "Unknown function '$func_name'"; return 1 ;;
  esac
}


#-------------------------------------------------------------------------------------------------
# Script Checks
#-------------------------------------------------------------------------------------------------

# Fail if this script is not being sourced
require_script_sourcing "${BASH_SOURCE[0]}" "$LINENO"

