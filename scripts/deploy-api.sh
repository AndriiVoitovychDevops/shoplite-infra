#!/usr/bin/env bash
# Run on DevOps1 from repo root: copy app to api VM and provision it.
set -euo pipefail

API="vagrant@192.168.56.30"
KEY="$HOME/.ssh/shoplite"

set -a; source .env; set +a

# TODO: твій рядок scp, тільки замість ключа й адреси $KEY і $API

ssh -i "$KEY" "$API" \
  "sudo DB_HOST='$DB_HOST' DB_NAME='$DB_NAME' DB_USER='$DB_USER' DB_PASSWORD='$DB_PASSWORD' bash -s" < scripts/api.sh