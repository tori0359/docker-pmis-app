#!/usr/bin/env bash

set -e

if [ -f "/usr/local/src/pmis.war" ]; then
    rm -rf /usr/local/pmis/ROOT
    mv -f /usr/local/src/pmis.war /usr/local/pmis/pmis.war
fi

exec catalina.sh run