# catalog-api

A tiny read-only product catalog for ShopLite (Python 3 + Flask, MariaDB).
The application code is deliberately small: the point of this repo is how
the service is built, configured, deployed, observed and fixed, not the code itself.

## Endpoints

| Method | Path | Purpose | Touches DB |
|---|---|---|---|
| GET | `/health` | Liveness: the process is up | no |
| GET | `/ready` | Readiness: the database answers (`503` if not) | yes |
| GET | `/products` | List all products | yes |
| GET | `/products/<id>` | One product, `404` if missing | yes |

## Configuration (environment variables)

| Variable | Required | Default | Notes |
|---|---|---|---|
| `DB_HOST` | yes | | MariaDB host or IP |
| `DB_PORT` | no | `3306` | |
| `DB_NAME` | yes | | |
| `DB_USER` | yes | | |
| `DB_PASSWORD` | yes | | Never commit it |
| `DB_CONNECT_TIMEOUT` | no | `3` | Seconds |
| `APP_VERSION` | no | `dev` | Shown in `/health` |
| `LOG_LEVEL` | no | `INFO` | Logs go to stdout |

The process exits with code `1` at startup if a required variable is missing.

## Run it

```bash
python3 -m venv /opt/catalog-api/venv
/opt/catalog-api/venv/bin/pip install -r requirements.txt

# Database side (once): create the table and seed rows
mysql -h "$DB_HOST" -u "$DB_USER" -p "$DB_NAME" < schema.sql

# Serve it (from the directory that contains app.py)
/opt/catalog-api/venv/bin/gunicorn --workers 2 --bind 0.0.0.0:8000 app:app
```

Smoke test:

```bash
curl -s localhost:8000/health
curl -s localhost:8000/ready
curl -s localhost:8000/products
```

## Not covered here on purpose

The service unit, the system user, where the code and the env file live on
disk, the database and its user, the firewall: that is infrastructure work and
belongs in `vagrant/` and `scripts/`.
