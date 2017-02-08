#!/usr/bin/env bash

set -e

if [ -d "/usr/local/src" ]; then
    rm -rf /usr/local/tomcat/webapps/ROOT
    mv -f /usr/local/src/stnd_pmis.war /usr/local/tomcat/webapps/
    rm -r /usr/local/src
fi

exec catalina.sh run