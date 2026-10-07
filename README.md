# ShopLite infra

Infrastructure for **ShopLite**, a tiny online shop used as a hands-on DevOps project.
A read-only product catalog API runs on one VM and reads products from MariaDB on another.
Everything after `vagrant up` is done by idempotent shell scripts: rebuild a VM from zero, run the scripts, get the same result.

## Architecture

```
browser ──HTTP :8000──▶  api  (192.168.56.30, Ubuntu 24.04)
                         catalog-api: Flask + gunicorn, systemd service, user "catalog"
                           │
                           │ MySQL :3306 (firewalld allows only 192.168.56.30)
                           ▼
                         db   (192.168.56.31, Rocky Linux 9)
                         MariaDB, database "shoplite", user "catalog_api" (SELECT only)
```

| Machine | Role |
|---|---|
| Windows host | Runs VirtualBox + Vagrant, only creates the VMs |
| DevOps1 (Ubuntu VM) | Workstation: git, SSH key, runs the deploy scripts |
| api | Runs the catalog API |
| db | Runs MariaDB |

## Repository layout

| Path | What it is |
|---|---|
| `Vagrantfile` | Creates the `api` and `db` VMs and installs the SSH key |
| `scripts/bootstrap-ssh-key.sh` | Vagrant provisioner: adds `~/.ssh/shoplite.pub` to the `vagrant` user |
| `scripts/db.sh` | Runs **on db**: MariaDB, firewall rule, database, least-privilege user |
| `scripts/api.sh` | Runs **on api**: packages, `catalog` user, app, venv, env file, systemd service |
| `scripts/deploy-db.sh` | Runs **on DevOps1**: sends `db.sh` and `schema.sql` to db |
| `scripts/deploy-api.sh` | Runs **on DevOps1**: copies the app to api and runs `api.sh` there |
| `systemd/catalog-api.service` | systemd unit for the API (auto start, restart on failure) |
| `app/catalog-api/` | Application code and `schema.sql` ([its own README](app/catalog-api/README.md)) |
| `.env.example` | Template for the settings and secrets the deploy scripts need |

## Requirements

- VirtualBox and Vagrant on the host
- An SSH key pair for this project: private key `~/.ssh/shoplite` on the workstation, public key at `~/.ssh/shoplite.pub` on the Vagrant host (or set `SHOPLITE_PUBKEY`)
- Bash, `ssh` and `scp` on the workstation

Generate the key once:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/shoplite -C "shoplite-lab"
```

## Deploy

1. **Create the VMs** (on the Vagrant host, from the repo root):
   ```bash
   vagrant up
   ```
2. **Configure secrets** (on the workstation, from the repo root):
   ```bash
   cp .env.example .env    # then set a real DB_PASSWORD; .env is gitignored
   ```
3. **Provision the database, then the API:**
   ```bash
   ./scripts/deploy-db.sh
   ./scripts/deploy-api.sh
   ```

All scripts are safe to run again. Re-running `deploy-api.sh` is also how you ship a new version of the app.

## Check

```bash
curl http://192.168.56.30:8000/health     # {"status": "ok", ...}
curl http://192.168.56.30:8000/ready      # {"status": "ready"}, or 503 if the DB is unreachable
curl http://192.168.56.30:8000/products   # 4 products
```

On the api VM:

```bash
systemctl status catalog-api
journalctl -u catalog-api -f
```

## Security notes

- The API connects as `catalog_api@192.168.56.30` with `SELECT` only; it cannot change data.
- Port 3306 on db is open to the api IP only.
- MariaDB `root` works only locally on db (unix socket).
- `/etc/catalog-api/env` holds the DB password: owner `root`, group `catalog`, mode `640`.
- The service runs as the system user `catalog` (no home, no shell).
- Lab shortcut: the password is passed on the remote command line, so it is briefly visible in `ps` on the VM.

## Rebuild from zero

```bash
vagrant destroy -f api && vagrant up api      # on the Vagrant host
ssh-keygen -R 192.168.56.30                   # on the workstation: forget the old host key
./scripts/deploy-api.sh
```
