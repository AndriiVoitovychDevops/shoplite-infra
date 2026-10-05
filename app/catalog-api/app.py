"""ShopLite catalog-api: a tiny read-only product catalog backed by MariaDB.

All configuration comes from environment variables, so the same code runs
on a VM (systemd EnvironmentFile), in Docker (-e / env_file) and in
Kubernetes (ConfigMap + Secret) without changes.
"""

import logging
import os
import sys

import pymysql
from flask import Flask, jsonify

logging.basicConfig(
    stream=sys.stdout,
    level=os.environ.get("LOG_LEVEL", "INFO").upper(),
    format="%(asctime)s %(levelname)s %(name)s: %(message)s",
)
log = logging.getLogger("catalog-api")

REQUIRED_VARS = ("DB_HOST", "DB_NAME", "DB_USER", "DB_PASSWORD")


def load_config():
    missing = [name for name in REQUIRED_VARS if not os.environ.get(name)]
    if missing:
        # Fail fast: a service that starts without its config only fails later, and more confusingly.
        log.critical("Missing required environment variables: %s", ", ".join(missing))
        sys.exit(1)
    return {
        "host": os.environ["DB_HOST"],
        "port": int(os.environ.get("DB_PORT", "3306")),
        "database": os.environ["DB_NAME"],
        "user": os.environ["DB_USER"],
        "password": os.environ["DB_PASSWORD"],
        "connect_timeout": int(os.environ.get("DB_CONNECT_TIMEOUT", "3")),
    }


DB = load_config()
APP_VERSION = os.environ.get("APP_VERSION", "dev")

app = Flask(__name__)


def db_connect():
    # One connection per request: simple and good enough for a lab, not for high load.
    return pymysql.connect(cursorclass=pymysql.cursors.DictCursor, **DB)


@app.get("/health")
def health():
    """Liveness: the process is up and serving HTTP. Never touches the database."""
    return jsonify(status="ok", version=APP_VERSION)


@app.get("/ready")
def ready():
    """Readiness: the service can do useful work, i.e. the database answers."""
    try:
        with db_connect() as conn, conn.cursor() as cur:
            cur.execute("SELECT 1")
        return jsonify(status="ready")
    except pymysql.MySQLError as exc:
        log.error("Readiness check failed: %s", exc)
        return jsonify(status="not ready"), 503


@app.get("/products")
def list_products():
    try:
        with db_connect() as conn, conn.cursor() as cur:
            cur.execute("SELECT id, name, price, stock FROM products ORDER BY id")
            rows = cur.fetchall()
    except pymysql.MySQLError as exc:
        log.error("Failed to list products: %s", exc)
        return jsonify(error="database unavailable"), 503
    for row in rows:
        row["price"] = str(row["price"])
    return jsonify(rows)


@app.get("/products/<int:product_id>")
def get_product(product_id):
    try:
        with db_connect() as conn, conn.cursor() as cur:
            cur.execute(
                "SELECT id, name, price, stock FROM products WHERE id = %s",
                (product_id,),
            )
            row = cur.fetchone()
    except pymysql.MySQLError as exc:
        log.error("Failed to get product %s: %s", product_id, exc)
        return jsonify(error="database unavailable"), 503
    if row is None:
        return jsonify(error="not found"), 404
    row["price"] = str(row["price"])
    return jsonify(row)


if __name__ == "__main__":
    # Local debugging only. On servers run it under gunicorn (see README).
    app.run(host="127.0.0.1", port=int(os.environ.get("APP_PORT", "8000")))
