#!/usr/bin/env bash

#export CERTBOT_CERTS_PATH=/etc/letsencrypt
#export CERTBOT_HOST=dev.sangah.com
#export CERTBOT_EMAIL=pmis@sangah.com

SCRIPT_BASE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

cd "$SCRIPT_BASE_PATH"

docker-compose -f docker-compose.yml -f docker-compose-certgen.yml up -d