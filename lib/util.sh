#!/bin/bash
matches() {
  local match
  if [ -t 0 ]; then
    match=$1; shift
  else
    match=$(cat -)
  fi
  local regex="$1"

  test -n "$(echo "$match" | grep "$regex")"
}

stderr() {
  echo "$@" >&2
}

putd() {
  stderr "$1=${!1}"
}
