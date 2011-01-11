#!/bin/bash
stderr() {
  echo "$@" >&2
}

putd() {
  stderr "$1=<${!1}>"
}

exists() {
  type "$@" >/dev/null 2>/dev/null
}

matches() {
  test -n $(
    if [ -n "$1" ]; then
      echo $1; shift
    else
      cat -
    fi | grep "$@"
  )
}

pluralize() {
  if [ -n "$1" ]; then
    # TODO: actually implement the inflector
    echo ${1}s
  else
    while read line; do
      pluralize $line
    done
  fi
}

trim() {
  trimmed="$1"
  trimmed="${trimmed##*( )}"
  trimmed="${trimmed%%*( )}"
}
