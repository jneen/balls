#!/bin/bash

_hash() {
  echo $$.$(date +'%s.%N').$RANDOM
}

balls::server() {
  balls::load_app
  http_sock=$BALLS_TMP/balls.http.$$.sock
  [ -p $http_sock ] || mkfifo $http_sock

  while true; do
    cat $http_sock | nc -l -p $BALLS_PORT | (
      http::parse_request
      balls::route > $http_sock
    )
  done
}

cleanup() {
  rm -f "$headers_sock" "$http_sock"
}

trap 'cleanup; exit' INT

balls::load_app() {
  . $BALLS_ACTIONS/*.sh
}
