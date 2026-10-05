#!/usr/bin/env bash
# Add the ShopLite public key to the vagrant user. Safe to run many times.
set -euo pipefail

: "${PUBKEY:?PUBKEY is required}"

SSH_DIR=/home/vagrant/.ssh
AUTH_KEYS="$SSH_DIR/authorized_keys"

mkdir -p "$SSH_DIR"
touch "$AUTH_KEYS"
grep -qxF "$PUBKEY" "$AUTH_KEYS" || echo "$PUBKEY" >> "$AUTH_KEYS"

chown -R vagrant:vagrant "$SSH_DIR"
chmod 700 "$SSH_DIR"
chmod 600 "$AUTH_KEYS"

echo "ShopLite key installed on $(hostname)"