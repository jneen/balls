#!/bin/bash

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

b:GET() { balls::define_route GET "$@" ;}
b:POST() { balls::define_route POST "$@" ;}
b:PUT() { balls::define_route PUT "$@" ;}
b:DELETE() { balls::define_route DELETE "$@" ;}

balls::route() {
  if [[ "$REQUEST_METHOD" = "HEAD" ]]; then
    body_sock=/dev/null
  fi

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

  if [ -n "$action" ] && exists "$action"; then
    headers_sock=$BALLS_TMP/balls.headers.$(_hash).sock
    [ -p $headers_sock ] || mkfifo $headers_sock

    ( $action 3>$headers_sock ) | {
      headers=$(cat <$headers_sock)
      body=$(cat -)

      response=$(
        echo "$headers"
        echo "Content-Length: ${#body}"
        echo "$body"
      )

      echo "$response" >$http_sock
    }
    # send the headers to the client
    rm -f "$headers_sock"
  else
    if [[ "$REQUEST_METHOD" = "HEAD" ]]; then
      REQUEST_METHOD=GET
      balls::route
    else
      http::status 404 > $http_sock
      http::content_type text/plain > $http_sock
      http::body > $http_sock
    fi

    echo "No route matched $REQUEST_METHOD $REQUEST_PATH" > $http_sock
    echo > $http_sock
  fi
}
