# `open-wearables/.env`

This file is **not** the root `.env`. Docker Compose uses root `.env` for ports and the Postgres *container* password. The Open Wearables **application** containers load **this** file.

Bootstrap creates it from upstream `backend/config/.env.example` and sets `DB_HOST=ow-db`, `REDIS_HOST=ow-redis`, disables Sentry/webhooks, and generates `SECRET_KEY`.

## You must set

| Variable | Rule |
|---|---|
| `ADMIN_EMAIL` | First admin login |
| `ADMIN_PASSWORD` | First admin login |
| `DB_PASSWORD` | **Identical** to `OW_DB_PASSWORD` in the repo-root `.env` |

Re-run `./scripts/bootstrap.sh` after changing `OW_DB_PASSWORD` — it rewrites `DB_PASSWORD` here.

Full setup (including **nginx :8080** for wger) lives in the **[root README](../README.md)**.
