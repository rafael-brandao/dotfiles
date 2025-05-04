#! /usr/bin/env bash

# shellcheck shell=bash

# Return early if this script was already sourced

[ -z "${__SHELL_UTILS_SOURCED-}" ] || return 0
__SHELL_UTILS_SOURCED=1


__UTILS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${__UTILS_DIR}/functions.bash" # Source functions.bash
. "${__UTILS_DIR}/paths.bash" # Source paths.bash


#-------------------------------------------------------------------------------------------------
# Script Checks
#-------------------------------------------------------------------------------------------------

# Fail if this script is not being sourced
require_script_sourcing "${BASH_SOURCE[0]}" "$LINENO"

