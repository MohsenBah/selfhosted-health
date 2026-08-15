# Use an existing Grafana (skip compose Grafana)

This stack does **not** require the bundled Grafana profile. Keep Open Wearables + wger (and their Postgres) on the always-on host; point any Grafana you already run at the two databases.

## 1. Start apps only

```bash
./scripts/bootstrap.sh
# fill .env / open-wearables/.env / wger/config/prod.env
# Grafana_* in root .env can stay commented — compose does not require them for wearables+gym

docker compose --profile wearables --profile gym up -d --build
# do NOT pass --profile grafana or --profile full
```

Default published Postgres ports (from root `.env`):

| Variable | Default host port | Database |
|---|---:|---|
| `OW_DB_PORT` | `5432` | Open Wearables |
| `WGER_DB_PORT` | `5433` | wger |

Restrict these ports to your Grafana host (firewall). Do **not** put them on a public reverse proxy.

## 2. Add two Postgres datasources

In Grafana → **Connections → Data sources → Add PostgreSQL** (twice):

| Name | Host | Database | User | Password |
|---|---|---|---|---|
| `openwearables` | `<health-host>:5432` | value of `OW_DB_NAME` (default `open-wearables`) | `OW_DB_USER` | `OW_DB_PASSWORD` |
| `wger` | `<health-host>:5433` | `WGER_DB_NAME` (default `wger`) | `WGER_DB_USER` | `WGER_DB_PASSWORD` |

Suggested JSON options: `sslmode=disable` on a trusted LAN; Postgres version **15+**. Prefer a **read-only** role for Grafana if you create one.

For a self-contained laptop demo, the compose Grafana profile still works (`--profile full` or `--profile grafana`) and uses Docker DNS names `ow-db` / `wger-db` via [grafana/provisioning/datasources/](../grafana/provisioning/datasources/).

## 3. Optional: import provisioning YAML

Copy `grafana/provisioning/datasources/datasources.yaml` into your Grafana provisioning tree, then **change**:

- `url: ow-db:5432` → `url: <health-host>:5432`
- `url: wger-db:5432` → `url: <health-host>:5433`
- passwords to match your `.env`

Dashboards under `grafana/dashboards/` can be imported manually or via your Grafana’s dashboard provisioning.

## Homelab pattern

Always-on: wearables + gym + Postgres.  
On-demand (Wake-on-LAN): Grafana only — wake when you want charts, not 24/7.

See also [homelab-placement.md](homelab-placement.md).
