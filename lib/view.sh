#!/bin/bash
esh=$(readlink -f $BALLS_LIB/../bin/esh)
render::esh() {
  local view="$BALLS_VIEWS/$1"
  local compiled="$(esh::compile "$view")"

  # source it in a subshell so it gets our variables
  ( . "$compiled" )
}

esh::compile() {
  local view="$1"
  local compiled_fname="$view.o"

  if [[ ! -f "$compiled_fname" ]] || [[ "$view" -nt "$compiled_fname" ]]; then
    $esh "$view" > "$compiled_fname"
  fi

  echo "$compiled_fname"
}
