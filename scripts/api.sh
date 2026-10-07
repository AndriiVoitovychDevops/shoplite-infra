#!/usr/bin/env bash
#Prepare api VM for catalog-api. Safe to run many times.

set -euo pipefail

: "${DB_HOST:?DB_HOST is required}"
: "${DB_NAME:?DB_NAME is required}"
: "${DB_USER:?DB_USER is required}"
: "${DB_PASSWORD:?DB_PASSWORD is required}"

log() { echo "[api] $*"; }

apt-get update && apt-get install -y python3-venv mariadb-client nginx

id catalog >/dev/null 2>&1 || useradd --system --no-create-home --shell /usr/sbin/nologin catalog

install -d -o root -g catalog -m 755 /opt/catalog-api
install -d -o root -g catalog -m 750 /etc/catalog-api
install -m 644 /tmp/app.py /tmp/requirements.txt /opt/catalog-api/

cat > /etc/catalog-api/env <<EOF
DB_HOST=${DB_HOST}
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
EOF
chown root:catalog /etc/catalog-api/env
chmod 640 /etc/catalog-api/env

cat > /etc/nginx/sites-available/catalog-api <<'EOF'
server {
    listen 80;

    location / {
        proxy_pass http://127.0.0.1:8000;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

ln -sf /etc/nginx/sites-available/catalog-api /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl reload nginx

install -m 644 /tmp/catalog-api.service /etc/systemd/system/

[ -d /opt/catalog-api/venv ] || python3 -m venv /opt/catalog-api/venv
/opt/catalog-api/venv/bin/pip install -r /opt/catalog-api/requirements.txt

systemctl daemon-reload
systemctl enable catalog-api
systemctl restart catalog-api

log "Done"