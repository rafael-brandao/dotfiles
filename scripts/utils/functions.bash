#! /usr/bin/env bash

# shellcheck shell=bash

# Return early if this script was already sourced
[ -z "${__SHELL_UTIL_FUNCTIONS_SOURCED-}" ] || return 0
__SHELL_UTIL_FUNCTIONS_SOURCED=1


#-------------------------------------------------------------------------------------------------
# Setup colors, but only if connected to a terminal
#-------------------------------------------------------------------------------------------------
if [ -t 1 ]; then
  # BLUE=$(printf '\033[34m')
  # DARK_GRAY=$(printf '\033[90m')
  # GRAY=$(printf '\033[37m')
  GREEN=$(printf '\033[32m')
  RED=$(printf '\033[31m')
  YELLOW=$(printf '\033[33m')
  BOLD=$(printf '\033[1m')
  RESET=$(printf '\033[m')
else
  # BLUE=""
  # DARK_GRAY=""
  # GRAY=""
  GREEN=""
  RED=""
  YELLOW=""
  BOLD=""
  RESET=""
fi


#-------------------------------------------------------------------------------------------------
# Common Functions
#-------------------------------------------------------------------------------------------------
info() {
  printf >&2 '%s\n' "$*"
}

success() {
  printf >&2 '%s\n' "${BOLD}${GREEN}$*${RESET}"
}

error() {
  printf >&2 '%s\n' "${RED}$*${RESET}"
}

warn() {
  printf >&2 '%s\n' "${BOLD}${YELLOW}$*${RESET}"
}

underline() {
  echo "$(printf '\033[4m')$*$(printf '\033[24m')"
}

fail() {
  local error_code error_message

  if [ "$#" -gt 1 ]; then
    error_code="$1"
    error_message="$2"
  else
    error_code=1
    error_message="$1"
  fi

  error "$error_message"
  exit $((error_code))
}

require_script_sourcing() {
  local lineno script

  if [ "$#" -gt 1 ]; then
    script="$1"
    lineno="$2"
  else
    script="${BASH_SOURCE[1]}"
    lineno="${1-}"
  fi

  [ "$script" != "$0" ] || {
    if [ -n "$lineno" ]; then
      fail 255 "$script: $lineno: $(basename "$script") is supposed to be sourced"
    else
      fail 255 "$script $(basename "$script") is supposed to be sourced"
    fi
  }
}

require_script_execution() {
  local lineno script

  if [ "$#" -gt 1 ]; then
    script="$1"
    lineno="$2"
  else
    script="${BASH_SOURCE[1]}"
    lineno="${1-}"
  fi

  [ "$script" == "$0" ] || {
    if [ -n "$lineno" ]; then
      fail 254 "$script: $lineno: $(basename "$script") is supposed to be executed"
    else
      fail 254 "$script $(basename "$script") is supposed to be executed"
    fi
  }
}


#-------------------------------------------------------------------------------------------------
# Script Checks
#-------------------------------------------------------------------------------------------------

# Fail if this script is not being sourced
require_script_sourcing "${BASH_SOURCE[0]}" "$LINENO"
