#!/usr/bin/env bash
set -euo pipefail

API="vagrant@192.168.56.31"
KEY="$HOME/.ssh/shoplite"

set -a; source .env; set +a

ssh -i "$KEY" "$API" \
  "sudo DB_NAME='$DB_NAME' DB_USER='$DB_USER' DB_PASSWORD='$DB_PASSWORD' API_IP='$API_IP' bash -s" < scripts/db.sh

  ssh -i "$KEY" "$API" \
  "sudo mysql $DB_NAME" < app/catalog-api/schema.sql
