# Self-Hosted Health

**Own the store. Treat every wearable as a disposable feeder.**

A demo-ready stack that keeps your health and gym data on infrastructure you control:

| Layer | Component | Role |
|---|---|---|
| **Wearables hub** | [Open Wearables](https://github.com/the-momentum/open-wearables) | Ingest + normalize Garmin, Polar, Oura, Apple HealthKit, … |
| **Gym tracker** | [wger](https://github.com/wger-project/wger) | Daily lifting, routines, nutrition + Flutter phone app |
| **Show layer** | Grafana | Join both Postgres databases — no app-to-app sync |
| **Insurance** | `scripts/backup.sh` | Nightly `pg_dump` so a dead upstream is not a dead archive |

```
Garmin / Polar H10 / (later Oura, HealthKit)
        │
        ▼
┌───────────────────┐     ┌──────────────┐
│  Open Wearables   │     │     wger     │◄── you at the gym (Flutter)
│  (Postgres)       │     │  (Postgres)  │
└─────────┬─────────┘     └──────┬───────┘
          │                      │
          └──────────┬───────────┘
                     ▼
              ┌─────────────┐
              │   Grafana   │  demo dashboards
              └─────────────┘
                     │
                     ▼
              pg_dump archive  ← what you actually own
```

## Why this shape

- **All data first** — Open Wearables stores generic time series even for metrics you never chart.
- **Swap gadgets** — add Oura or Polar without changing the gym app or the archive format.
- **No redundant sync** — sleep/HRV/steps have nowhere useful in wger; body weight is the only real overlap. Join in Grafana instead of copying rows.
- **Not a map app** — FitTrackee and outdoor GPX archives are out of scope here.
- **Show-off friendly** — one `docker compose` story for demos: wearables API + gym UI + Grafana.

Upstream licenses stay upstream (Open Wearables MIT, wger AGPL-3.0). This repo is glue, docs, and Grafana provisioning (MIT).

## Quick start

```bash
# 1. Clone this repo
git clone <your-fork-or-path> selfhosted-health && cd selfhosted-health

# 2. Pull Open Wearables source (pinned) + write env files
./scripts/bootstrap.sh

# 3. Edit secrets
cp .env.example .env          # fill passwords / admin accounts
# also: open-wearables/.env and wger/config/prod.env (created by bootstrap)

# 4. Bring the stack up (builds Open Wearables images on first run)
docker compose --profile full up -d --build

# 5. Open
#   Open Wearables UI:  http://localhost:3000
#   Open Wearables API: http://localhost:8000/docs
#   wger:               http://localhost:8080
#   Grafana:            http://localhost:3001  (admin / see .env)
```

First Open Wearables build can take several minutes (Python + frontend images).

### Profiles

| Profile | What starts |
|---|---|
| `wearables` | Open Wearables only (trimmed: no Flower, no Svix) |
| `gym` | wger only |
| `grafana` | Grafana only (expects DBs already up) |
| `full` | Wearables + wger + Grafana |

```bash
docker compose --profile wearables up -d --build
docker compose --profile gym up -d
docker compose --profile full up -d --build
```

## Demo walkthrough

See [docs/demo-walkthrough.md](docs/demo-walkthrough.md) for a 5-minute script (connect a provider → log a workout in wger → show Grafana join).

Architecture notes: [docs/architecture.md](docs/architecture.md).  
Homelab placement (Proxmox CT sizing): [docs/homelab-placement.md](docs/homelab-placement.md).

## Backup (the part that matters)

```bash
./scripts/backup.sh ./backups
# produces timestamped dumps of both Postgres databases
```

Restore is documented in the script header. Schedule this from cron or your CT backup job — **the dumps are the durable asset**, not the container images.

## What this is not

- Not a medical device / not clinical advice.
- Not a Strava/Garmin Connect replacement for social features.
- Not “sync Open Wearables into wger” — that path is deliberately rejected (see architecture doc).

## Credits

- [the-momentum/open-wearables](https://github.com/the-momentum/open-wearables)
- [wger-project/wger](https://github.com/wger-project/wger) + [wger-project/docker](https://github.com/wger-project/docker) + [wger-project/flutter](https://github.com/wger-project/flutter)
- Grafana Labs
