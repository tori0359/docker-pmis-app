#!/usr/bin/env bash

set -e

if [ -f "/usr/local/src/stnd_pmis.war" ]; then
    rm -rf /usr/local/pmis/ROOT
    mkdir -p /usr/local/pmis && mv -f /usr/local/src/stnd_pmis.war /usr/local/pmis/pmis.war
fi

JVM_ROUTE=${JVM_ROUTE:-worker1}
sed -i 's/worker1/$JVM_ROUTE/' /usr/local/tomcat/conf/server.xml

if [ $# -eq 0 ]; then
    # if no arguments are supplied start apache
    exec catalina.sh run
fi

exec "$@"