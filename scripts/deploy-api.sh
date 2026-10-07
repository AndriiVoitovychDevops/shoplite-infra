#!/usr/bin/env bash
set -euo pipefail

API="vagrant@192.168.56.30"
KEY="$HOME/.ssh/shoplite"

set -a; source .env; set +a

scp -i "$KEY" app/catalog-api/app.py app/catalog-api/requirements.txt systemd/catalog-api.service "$API":/tmp/

ssh -i "$KEY" "$API" \
  "sudo DB_HOST='$DB_HOST' DB_NAME='$DB_NAME' DB_USER='$DB_USER' DB_PASSWORD='$DB_PASSWORD' bash -s" < scripts/api.sh