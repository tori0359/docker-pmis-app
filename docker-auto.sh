#!/usr/bin/env bash

set -e

SCRIPT_BASE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd "$SCRIPT_BASE_PATH"

usage() {
echo "Usage:  $(basename "$0") [MODE] [OPTIONS] [COMMAND]"
echo 
echo "Mode:"
echo "  --prod          Mode: production"
echo "  --dev           Mode: development"
echo "  --fulldev       Mode: full development mode with all services running"
echo "  --with-hub      Mode: production with service controlled by the hub"
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
}

CONF_ARG=""

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

for i in "$@"
do
case $i in
    --prod)
        CONF_ARG="$CONF_ARG -f docker-compose.yml"
        shift
        ;;
    --dev)
        CONF_ARG="$CONF_ARG -f docker-compose-dev.yml"
        shift
        ;;
    --fulldev)
        CONF_ARG="$CONF_ARG -f docker-compose-dev-full.yml"
        shift
        ;;
    --jmx)
        CONF_ARG="$CONF_ARG -f docker-compose-jmx.yml"
        shift
        ;;
    --with-hub)
        CONF_ARG="$CONF_ARG -f docker-compose-with-hub.yml"
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
    docker-compose $CONF_ARG up -d
    exit 0
elif [ "$1" == "stop-all" ] && [ "$(docker ps --format {{.ID}})" != ""]; then
    docker stop $(docker ps --format {{.ID}})
    exit 0
elif [ "$1" == "remove-all" ] && [ "$(docker ps -a --format {{.ID}})" != "" ]; then
    docker rm $(docker ps -a --format {{.ID}})
    exit 0
elif [ "$1" == "logs" ]; then
    docker-compose $CONF_ARG logs -f --tail 200
    exit 0
fi

docker-compose $CONF_ARG "$@"
