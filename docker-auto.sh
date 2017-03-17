#!/usr/bin/env bash

set -e

PROJECT_NAME="$PROJECT_NAME"
if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME="$(cat .env | awk 'BEGIN { FS="="; } /^PROJECT_NAME/ {sub(/\r/,"",$2); print $2;}')"
fi
REGISTRY_URL="$REGISTRY_URL"
if [ -z "$REGISTRY_URL" ]; then
    REGISTRY_URL="$(cat .env | awk 'BEGIN { FS="="; } /^REGISTRY_URL/ {sub(/\r/,"",$2); print $2;}')"
fi

SCRIPT_BASE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd "$SCRIPT_BASE_PATH"

usage() {
echo "Usage:  $(basename "$0") [MODE] [OPTIONS] [COMMAND]"
echo 
echo "Mode:"
echo "  --prod          Production mode with all services running"
echo "  --prod-was      Production mode with only was (tomcat) running"
echo "  --dev           Development mode with only was running"
echo "  --fulldev       Development mode with all services running"
echo "  --with-hub      Production mode only was and httpd - have to run under the hub web server"
echo
echo "Options:"
echo "  --jmx           Add JMX support"
echo "  --certgen       Run the certbot instance for generating SSL certificate"
echo "  --help          Show this help message"
echo
echo "Commands:"
echo "  up              Start the services"
echo "  down            Stop the services"
echo "  ps              Show the status of the services"
echo "  logs            Follow the logs on console"
echo "  remove-all      Remove all containers"
echo "  stop-all        Stop all containers running"
echo "  build           Build the image"
echo "  publish         Publish the image to the registry"
}

CONF_ARG="-f docker-compose-prod-full.yml"

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

for i in "$@"
do
case $i in
    --prod)
        CONF_ARG="-f docker-compose-prod-full.yml"
        shift
        ;;
    --prod-was)
        CONF_ARG="-f docker-compose-prod-was.yml"
        shift
        ;;
    --with-hub)
        CONF_ARG="-f docker-compose-prod-with-hub.yml"
        shift
        ;;
    --dev)
        CONF_ARG="-f docker-compose-dev.yml"
        shift
        ;;
    --fulldev)
        CONF_ARG="-f docker-compose-dev-full.yml"
        shift
        ;;
    --jmx)
        CONF_ARG="$CONF_ARG -f docker-compose-jmx.yml"
        shift
        ;;
    --certgen)
        CONF_ARG="$CONF_ARG -f docker-compose-certgen.yml"
        shift
        ;;
    --help|-h)
        usage
        exit 1
        ;;
    *)
        ;;
esac
done

echo "Arguments: $CONF_ARG"
echo "Command: $@"

if [ "$1" == "up" ]; then
    docker-compose $CONF_ARG pull
    docker-compose $CONF_ARG build --pull
    docker-compose $CONF_ARG up -d --remove-orphans
    exit 0

elif [ "$1" == "stop-all" ]; then
    if [ -n "$(docker ps --format {{.ID}})" ]
    then docker stop $(docker ps --format {{.ID}}); fi
    exit 0

elif [ "$1" == "remove-all" ]; then
    if [ -n "$(docker ps -a --format {{.ID}})" ]
    then docker rm $(docker ps -a --format {{.ID}}); fi
    exit 0

elif [ "$1" == "logs" ]; then
    shift
    docker-compose $CONF_ARG logs -f --tail 200 "$@"
    exit 0

elif [ "$1" == "build" ]; then
    if [ -z "$REGISTRY_URL" ]; then echo "REGISTRY_URL not defined."; exit 1; fi
    if [ -z "$PROJECT_NAME" ]; then echo "PROJECT_NAME not defined."; exit 1; fi
    
    docker build -t $REGISTRY_URL/$PROJECT_NAME was
    exit 0

elif [ "$1" == "publish" ]; then
    if [ -z "$REGISTRY_URL" ]; then echo "REGISTRY_URL not defined."; exit 1; fi
    if [ -z "$PROJECT_NAME" ]; then echo "PROJECT_NAME not defined."; exit 1; fi
    
    docker login $REGISTRY_URL
    docker push $REGISTRY_URL/$PROJECT_NAME
    exit 0
fi

docker-compose $CONF_ARG "$@"
