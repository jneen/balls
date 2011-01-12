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
  grep "$@" >/dev/null
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

#trim() {
#  trimmed="$1"
#  trimmed="${trimmed##*( )}"
#  trimmed="${trimmed%%*( )}"
#}

read_char() {
  IFS= read -d"$(echo -e '\004')" -n1 "$@"
}

read_until() {
  local glob=$1; shift
  local var=$1; shift

  local out

  while read_char ch; do
    out="${out}${ch}"
    case "$out" in
      *$glob)
        FOUND=1
        export $var="${out%$glob}"
        return 0
      ;;
    esac
  done

  # we've hit an EOF
  if [ -z "$out" ]; then
    false
  else
    FOUND=0
    export $var="$out"
    true
  fi
}

trim_l() {
  local str=${!1}
  str="${str##+([[:space:]])}"
  export "$1"="$str"
}

trim_r() {
  local str=${!1}
  str="${str%%+([[:space:]])}"
  export "$1"="$str"
}

trim() {
  trim_l "$@"
  trim_r "$@"
}

# escape ' with '\''.  sorry everyone.
bash_safe() {
  local str="${!1}."
  str="$(echo "$str" | sed "s/'/'\\\\''/g")"
  export "$1"="'${str:0:${#str}-1}'"
}
