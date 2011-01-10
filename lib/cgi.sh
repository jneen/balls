#!/bin/bash
# /var/www/cgi-bin/balls.sh
[[ -z "$BALLS_CONFIG" ]] && BALLS_CONFIG=$PWD/config.sh

balls route $BALLS_CONFIG
