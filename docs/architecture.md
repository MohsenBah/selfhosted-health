# Architecture

## Design rules

1. **Own the store** — Postgres dumps outlive any app. If Open Wearables or wger stalls, history is still recoverable.
2. **Feeders are disposable** — Garmin SSO, Oura OAuth, Polar tokens will break. Replace connectors; do not reshape the archive around one vendor.
3. **Do not sync the two apps** — wger’s health surface today is essentially `weightentry` + `measurement`. Sleep, HRV, steps, GPS, readiness have no good home there. Overlap is ~1 field (body weight).
4. **Join at query time** — Grafana (or anything with two SQL datasources) is the demo and ops view.

## Components

### Open Wearables (wearables hub)

- FastAPI + Celery + Redis + Postgres 18
- Provider adapters: Garmin, Polar, Oura, Apple (HealthKit SDK / XML), Fitbit, WHOOP, Strava, …
- This stack runs a **trimmed** deploy: `db`, `redis`, `app`, `celery-worker`, `celery-beat`, `frontend`
- Omitted on purpose: `flower` (Celery UI), `svix-server` (outbound webhooks) — set `OUTGOING_WEBHOOKS_ENABLED=false`

### wger (gym)

- Django + Postgres + Redis + Celery + nginx
- Official `wger/server` images
- PowerSync omitted in this showcase (mobile Flutter app talks HTTP API; PowerSync is optional offline sync)

### Grafana

- Provisioned datasources for both Postgres instances
- Demo dashboard: gym volume + wearable daily metrics side by side (fill in once you have data)

## Data ownership matrix

| Data | Owner | Notes |
|---|---|---|
| Sleep, HRV, stress, SpO2, steps, readiness | Open Wearables | |
| GPS activities / outdoor | Open Wearables (if you care) | Not a focus of this stack |
| Strength sets, routines, nutrition | wger | Source of truth for the gym |
| Body weight | Prefer Open Wearables (scale/watch) | Optional display copy in wger — do not dual-write |

## Threat / ops notes for demos

- Do not expose admin UIs or DB ports publicly without SSO/VPN (NetBird / Pangolin).
- Rotate `SECRET_KEY` / Django `SECRET_KEY` before any real deployment.
- Open Wearables is early-stage — pin the git commit via `scripts/bootstrap.sh` and expect API churn.
