#!/bin/bash
balls::server() {
  local sock=$BALLS_SOCK
  [[ -z "$sock" ]] && sock=./tmp/balls.sock
  [ -p $sock ] || mkfifo $sock

putd ROUTES
  while true ; do
    ( cat $sock ) | nc -l -p 9009 | (
      local REQ=$(while read L && [ " " "<" "$L" ] ; do echo "$L" ; done)
      balls::parse_http

putd ROUTES
      balls::route > $sock
    )
  done
}

balls::parse_http() {
  local req_line=$(echo "$REQ" | head -1)
  req_line=($req_line)

  export REQUEST_METHOD=${req_line[0]}

  export REQUEST_URI=${req_line[1]}
  export REQUEST_PATH=${REQUEST_URI%%\?*}
  export QUERY_STRING=${REQUEST_URI#*\?}

  export VERSION=${req_line[2]}

  export SERVER_SOFTWARE="balls_cgi/0.0"
}
