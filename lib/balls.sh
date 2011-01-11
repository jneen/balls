#!/bin/bash
[[ -z "$BALLS_LIB" ]] && BALLS_LIB=$(dirname $0)
. $BALLS_LIB/util.sh
. $BALLS_LIB/http.sh
. $BALLS_LIB/router.sh
. $BALLS_LIB/server.sh
