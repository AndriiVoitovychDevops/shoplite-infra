#!/usr/bin/env bash
# Provision MariaDB for ShopLite on Rocky Linux 9. Safe to run many times.
set -euo pipefail

: "${DB_NAME:?DB_NAME is required}"
: "${DB_USER:?DB_USER is required}"
: "${DB_PASSWORD:?DB_PASSWORD is required}"
: "${API_IP:?API_IP is required}"

log() { echo "[db] $*"; }

if ! rpm -q mariadb-server >/dev/null 2>&1; then
    log "Installing mariadb-server"
    dnf install -y mariadb-server
fi

log "Allowing MariaDB from ${API_IP} only"
firewall-cmd --permanent --add-rich-rule="rule family=ipv4 source address=${API_IP}/32 port port=3306 protocol=tcp accept"
firewall-cmd --reload

systemctl enable --now mariadb

log "Creating database and user"
mysql <<SQL
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'${API_IP}' IDENTIFIED BY '${DB_PASSWORD}';
GRANT SELECT ON \`${DB_NAME}\`.* TO '${DB_USER}'@'${API_IP}';
SQL

log "Done"