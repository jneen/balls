#!/bin/bash

http::parse_request() {
  http::read req_line

  req_line=($req_line)
  export REQUEST_METHOD=${req_line[0]}

  export REQUEST_URI=${req_line[1]}
  export REQUEST_PATH=${REQUEST_URI%%\?*}
  export QUERY_STRING=${REQUEST_URI#*\?}

  export HTTP_VERSION=${req_line[2]}

  export SERVER_SOFTWARE="balls/0.0"

  declare -A HEADERS

  local key
  local val
  while http::read HEADER_LINE; do
    key="${HEADER_LINE%%*( ):*}"
    trim key
    val="${HEADER_LINE#*:*( )}"
    trim val

    HEADERS["$key"]="$val"
  done
}

http::read() {
  local __var=$1; shift
  read __in
  local RETVAL=$?

  # f-ing carriage returns
  __in=$(echo "$__in" | tr -d '\r')

  export "$__var"="$__in"

  # REQ="$(echo "$REQ"; echo "${!__var}")"

  [ "$RETVAL" = 0 ] && [ -n "${!__var}" ]
}

declare -a HTTP_STATUSES
HTTP_STATUSES[200]='OK'
HTTP_STATUSES[404]='Not Found'
HTTP_STATUSES[500]='Internal Server Error'

# TODO: lock this so it only happen once
http::status() {
  local code=$1;shift

  local message=$1;shift

  [ -z "$message" ] && message=${HTTP_STATUSES[$code]}

  http::header_echo "$HTTP_VERSION $code $message"
}

http::header() {
  local header_name=$1;shift
  local header_val=$1;shift
  http::header_echo "$header_name: $header_val"
}

http::header_echo() {
  echo "$@" >&3
}

http::content_type() {
  http::header 'Content-Type' "$@"
}
