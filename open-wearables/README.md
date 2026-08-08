# Env for the Open Wearables *app containers* (not root .env).
# bootstrap.sh copies upstream backend/config/.env.example here, then applies
# the overrides below. Keep DB_PASSWORD identical to OW_DB_PASSWORD in root .env.

# Minimal overrides you must set after bootstrap:
#   SECRET_KEY=
#   ADMIN_EMAIL=
#   ADMIN_PASSWORD=
#   DB_PASSWORD=   (same as OW_DB_PASSWORD)

DB_HOST=ow-db
REDIS_HOST=ow-redis
OUTGOING_WEBHOOKS_ENABLED=false
SENTRY_ENABLED=False
ENVIRONMENT="local"
FRONTEND_URL=http://localhost:3000
CORS_ORIGINS=["http://localhost:3000"]
