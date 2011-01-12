#!/bin/bash
esh=$(readlink -f $BALLS_LIB/../bin/esh)
render::esh() {
  local src="$($esh $BALLS_VIEWS/$1)"
  (
    eval "$src"
  )
}
