#!/bin/bash

[[ -z "$BALLS_DB_CREDENTIALS" ]] && BALLS_DB_CREDENTIALS=''
[[ -z "$BALLS_DB" ]] && BALLS_DB='balls'

balls::model::impl() {
  local model="$1"; shift

  local mode="$1"; shift

  if exists "$model.$mode"; then
    "$model.$mode" "$@"
  elif exists "$model::$mode"; then
    while read line; do
      balls::model.with "$line" "$model::$mode"
    done
  elif balls::model.fields | matches "^$mode\$"; then
    balls::model.field "$mode"
  elif exists "balls::model.$mode"; then
    "balls::model.$mode" "$@"
  else
    stderr "oh no! couldn't find \`$model.$mode\`."
  fi
}

balls::model.with() {
  local __data="$1"; shift
  local __callback="$1"; shift
  for __field in $(balls::model.fields); do
    local "$__field"="$(balls::model.field "$__field" <<<"$__data\n")"
    local "$__field"="$(balls::model.field "$__field" <<<"$__data\n")"
  done
  "$__callback" "$@"
}

balls::model() {
  alias "$1"="balls::model::impl $1"
  BALLS_LAST_MODEL="$1"
}

balls::model.find() {
  local query="$1"; shift
  for param in "$@"; do
    db_safe param
    query="${query/\?/$param}"
  done
  balls::model.execute "SELECT * from $(balls::model.table_name) WHERE $query"
}

balls::model.fetch_fields() {
  balls::model.execute "SHOW COLUMNS IN $(balls::model.table_name)" |\
    cut -f1 # bah
}

balls::model.fields() {
  local fields_var="$model"_FIELDS
  echo "${!fields_var}"
}

balls::model.field_map() {
  balls::model.fields | nl -nrz -ba
}

balls::model.column_number_for() {
  local field="$1"
  balls::model.field_map | grep "$field\$" | cut -f1
}

balls::model.field_at() {
  local idx="$1"
  balls::model.field_map | grep "^0*$idx" | cut -f2-
}

balls::model.field() {
  local idx="$(balls::model.column_number_for "$1")"
  cut -f"$idx"
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

balls::model.execute() {
  mysql $BALLS_DB_CREDENTIALS "$BALLS_DB" -e "$@" | tail -n+2 |\
    sed 's/NULL//g'
}

balls::model::load() {
  local file="$1"; shift

  . "$file"

  local model_name="$BALLS_LAST_MODEL"

  local fields_var="$model_name"_FIELDS
  #                 Person_FIELDS

  export "$fields_var"="$(balls::model::impl "$model_name" fetch_fields)"
}
