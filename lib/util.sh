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

test_grepq() {
  local output="$(echo x | grep -q x)"
  [[ $? == 0 ]] || return 1
  [[ -z "$output" ]] || return 1
  return 0
}

test_greps() {
  local output="$(echo x | grep -s x)"
  [[ $? == 0 ]] || return 1
  [[ -z "$output" ]] || return 1
  return 0
}

if test_grepq; then
  matches() { grep -q "$@" ;}
elif test_greps; then
  matches() { grep -s "$@" ;}
else
  matches() { grep "$@" 2>&1 >/dev/null ;}
fi

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

# for an explanation of this getc implementation, see
# http://write.jayferd.us/blog/2011/01/12/bash-adventures-read-a-single-character-even-if-its-a-newline/
getc() {
  IFS= read -r -n1 -d '' "$@"
}

read_until() {
  local glob=$1; shift
  local var=$1; shift

  local out

  while getc ch; do
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

# usage: db_safe my_var
# will quote my_var for mysql.
db_safe() {
  local str="${!1}." # append a . so that bash doesn't chomp off newlines at the end
  local escaped_quote="\\'"
  str="$(
    echo "${str//\'/$escaped_quote}" | while read line; do echo -n "$line\\n"; done)"
    #             ^ escape '          escape \n - bash has trouble with this one.
  export "$1"="'${str:0:${#str}-1}'" # enclose in single quotes, strip off the ., and export the variable
}

# escape ' with '\''.  sorry everyone.
bash_safe() {
  local str="${!1}"
  # escape ' with (literally) '\'' - sorry everyone
  local escaped_quote="'\\''"
  export "$1"="'${str//\'/$escaped_quote}'"
}

join() {
  local delim="$1"
  read line && echo -n "$line"
  while read line; do
    echo -n "$delim"
    echo -n "$line"
  done
}
