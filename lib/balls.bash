#!/bin/bash
[[ -z "$BALLS_LIB" ]] && BALLS_LIB=.

[[ -z "$BALLS_CONF" ]] && BALLS_CONF=./config.bash
[[ -z "$BALLS_ROOT" ]] && BALLS_ROOT=$(readlink -f "$(dirname $BALLS_CONF)/../")
[[ -z "$BALLS_LIB" ]] && BALLS_LIB=$(dirname $0)

[[ -z "$BALLS_TMP" ]] && BALLS_TMP=/tmp/balls
[[ -d "$BALLS_TMP" ]] || mkdir "$BALLS_TMP"

[[ -z "$BALLS_PORT" ]] && BALLS_PORT=3000

[[ -z "$BALLS_VIEWS" ]] && BALLS_VIEWS=$BALLS_ROOT/views
[[ -z "$BALLS_ACTIONS" ]] && BALLS_ACTIONS=$BALLS_ROOT/actions

. $BALLS_LIB/util.bash
. $BALLS_LIB/http.bash
. $BALLS_LIB/router.bash
. $BALLS_LIB/server.bash
. $BALLS_LIB/view.bash
. $BALLS_LIB/model.bash
