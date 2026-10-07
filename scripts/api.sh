#!/usr/bin/env bash
#Prepare api VM for catalog-api. Safe to run many times.

set -euo pipefail
log() { echo "[api] $*"; }

apt-get update && apt-get install -y python3-venv mariadb-client

id catalog >/dev/null 2>&1 || useradd --system --no-create-home --shell /usr/sbin/nologin catalog

install -d -o root -g catalog -m 755 /opt/catalog-api
install -d -o root -g catalog -m 750 /etc/catalog-api

log "Done"