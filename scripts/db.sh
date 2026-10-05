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

systemctl enable --now mariadb

# 3. Мережа: TODO
#    - На якій адресі слухає MariaDB зараз? Не вгадуй, перевір: ss -tlnp | grep 3306
#    - Firewalld: відкрити 3306 ЛИШЕ для API_IP (rich rule), а не для всіх.
#      Як зробити ідемпотентно? Подивись firewall-cmd --query-rich-rule

# 4. База і користувач: TODO
#    mysql -e "CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` ..."
#    CREATE USER IF NOT EXISTS '${DB_USER}'@'${API_IP}' ...
#    GRANT SELECT ON ...
#    ❓ IF NOT EXISTS не змінить пароль, якщо користувач уже є.
#       Що буде, коли ти зміниш DB_PASSWORD у .env? (ключове слово: ALTER USER)

log "Done"