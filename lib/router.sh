#!/bin/bash
# ROUTES=""
balls::define_route() {
  local verb=$1; shift
  local path=$1; shift
  local action=$1; shift

  local route_line="$(echo -e "$verb\t$path\t$action")"
  if [ -z "$ROUTES" ]; then
    ROUTES="$route_line"
  else
    ROUTES="$ROUTES
$route_line"
  fi
}

alias b:GET='balls::define_route GET'
alias b:POST='balls::define_route POST'
alias b:PUT='balls::define_route PUT'
alias b:DELETE='balls::define_route DELETE'

balls::route() {

stderr "begin balls::route"
putd REQUEST_METHOD
putd REQUEST_PATH
putd ROUTES

  local action=$(
    echo "$ROUTES" | grep "^$REQUEST_METHOD" | {
      while read line; do
        arr=($line)
        path=${arr[1]}
        act=${arr[2]}
        if [[ "$REQUEST_PATH" = "$path" ]]; then
          echo $act
          break
        fi
      done
    }
  )

putd action
stderr "$(type $action)"
  if [ -z "$action" ]; then
    true
    # 404
  elif [ -n "$(type $action)" ]; then
stderr LOL
    $action
  fi
}
