#!/bin/bash

[[ -z "$BALLS_DB_CREDENTIALS" ]] && BALLS_DB_CREDENTIALS=''
[[ -z "$BALLS_DB" ]] && BALLS_DB='balls'

balls::model::impl() {
  local model="$1"; shift

  local mode="$1"; shift

  if exists "$model.$mode"; then
    "$model.$mode" "$@"
  elif exists "balls::model.$mode"; then
    "balls::model.$mode" "$@"
  else
    stderr "oh no! couldn't find \`$model.$mode\`."
  fi
}

balls::model() {
  alias "$1"="balls::model::impl $1"
}

balls::model.find() {
  mysql $BALLS_DB_CREDENTIALS "$BALLS_DB" -e "SELECT * from $(balls::model.table_name) WHERE $@" | cat
}

balls::model.table_name() {
  local table_name_var="${model}_table_name"
  if [[ -n "$1" ]]; then
    export "$table_name_var"="$1"
  elif [[ -n "${!table_name_var}" ]]; then
    echo "${!table_name_var}"
  else
    echo "$model" | tr '[A-Z]' '[a-z]'
  fi
}
