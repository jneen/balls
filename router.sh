#!/bin/bash

matches() {
  local match
  if [ -t 0 ]
    match=$1; shift
  else
    match=$(cat -)
  fi
  local regex="$1"

  test -n "$(echo "$match" | grep "$regex")"
}

declare -a ROUTES
shweb::define_route() {
  verb=$1; shift
  path=$1; shift
  action=$1; shift
  ROUTES=$ROUTES"\n$verb\t$path\t$action"
}

alias GET='shweb::define_route GET'
alias POST='shweb::define_route POST'
alias PUT='shweb::define_route PUT'
alias DELETE='shweb::define_route DELETE'

GET /foo Foo::handle

shweb::route() {
  local path
  local act
  local arr
  local action=$(
    echo $ROUTES | grep "^$HTTP_METHOD" | {
      while read line; do
        local arr=($foo)
        path=${arr[1]}
        act=${arr[2]}
        if matches "$HTTP_REQUEST_PATH" "$path"; then
          echo $act
          break
        fi
      done
    }
  )
  if [ -z "$action" ]; then
    # 404
  elif [ -n "$(type $action)" ]; then
    $action
  fi
}
