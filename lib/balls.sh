#!/bin/bash
[[ -z "$BALLS_LIB" ]] && BALLS_LIB=$(dirname $0)

[[ -z "$TMP_DIR" ]] && TMP_DIR=/tmp/balls
[[ -d "$TMP_DIR" ]] && mkdir "$TMP_DIR"

[[ -z "$BALLS_PORT" ]] && BALLS_PORT=3000


. $BALLS_LIB/util.sh
. $BALLS_LIB/http.sh
. $BALLS_LIB/router.sh
. $BALLS_LIB/server.sh
