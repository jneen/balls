#!/bin/bash
# /var/www/cgi-bin/balls.bash
[[ -z "$BALLS_CONFIG" ]] && BALLS_CONFIG=$PWD/config.bash

balls route $BALLS_CONFIG
