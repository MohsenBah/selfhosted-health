#!/usr/bin/env bash
# Clone / update Open Wearables at a pinned commit and seed env files.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

OW_REPO="${OW_REPO:-https://github.com/the-momentum/open-wearables.git}"
# Pin for reproducible demos — bump deliberately after smoke-testing.
OW_REF="${OW_REF:-main}"
VENDOR="$ROOT/vendor/open-wearables"

echo "==> Open Wearables → $VENDOR ($OW_REF)"
if [[ ! -d "$VENDOR/.git" ]]; then
  mkdir -p "$ROOT/vendor"
  git clone --depth 1 --branch "$OW_REF" "$OW_REPO" "$VENDOR"
else
  git -C "$VENDOR" fetch --depth 1 origin "$OW_REF"
  git -C "$VENDOR" checkout -q FETCH_HEAD || git -C "$VENDOR" checkout -q "$OW_REF"
fi

PIN="$(git -C "$VENDOR" rev-parse --short HEAD)"
echo "    pinned at $PIN"
echo "$PIN" > "$ROOT/vendor/OPEN_WEARABLES_PIN.txt"

# --- Open Wearables app env ---
OW_ENV="$ROOT/open-wearables/.env"
OW_EXAMPLE="$VENDOR/backend/config/.env.example"
if [[ ! -f "$OW_ENV" ]]; then
  echo "==> Writing $OW_ENV from upstream example"
  cp "$OW_EXAMPLE" "$OW_ENV"
  # Demo-safe defaults: no Sentry noise, no outbound webhooks, local URLs
  if grep -q '^SENTRY_ENABLED=' "$OW_ENV"; then
    sed -i 's/^SENTRY_ENABLED=.*/SENTRY_ENABLED=False/' "$OW_ENV"
  fi
  if grep -q '^OUTGOING_WEBHOOKS_ENABLED=' "$OW_ENV"; then
    sed -i 's/^OUTGOING_WEBHOOKS_ENABLED=.*/OUTGOING_WEBHOOKS_ENABLED=false/' "$OW_ENV"
  fi
  if grep -q '^ENVIRONMENT=' "$OW_ENV"; then
    sed -i 's/^ENVIRONMENT=.*/ENVIRONMENT="local"/' "$OW_ENV"
  fi
  # Force DB/Redis service names used by our compose
  sed -i 's/^DB_HOST=.*/DB_HOST=ow-db/' "$OW_ENV" || true
  sed -i 's/^REDIS_HOST=.*/REDIS_HOST=ow-redis/' "$OW_ENV" || true
  echo
  echo "    EDIT open-wearables/.env — set SECRET_KEY, ADMIN_EMAIL, ADMIN_PASSWORD, DB_PASSWORD"
  echo "    Generate SECRET_KEY:  python3 -c \"import secrets; print(secrets.token_urlsafe(64))\""
else
  echo "==> Keeping existing $OW_ENV"
fi

# --- Root .env ---
if [[ ! -f "$ROOT/.env" ]]; then
  cp "$ROOT/.env.example" "$ROOT/.env"
  echo "==> Wrote .env from .env.example — fill passwords"
fi

# --- wger prod.env ---
WGER_ENV="$ROOT/wger/config/prod.env"
WGER_EXAMPLE="$ROOT/wger/config/prod.env.example"
if [[ -f "$ROOT/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$ROOT/.env" || true
  set +a
fi
WG_USER="${WGER_DB_USER:-wger}"
WG_PASS="${WGER_DB_PASSWORD:-change-me-wger-db}"
WG_NAME="${WGER_DB_NAME:-wger}"
OW_PASS="${OW_DB_PASSWORD:-change-me-ow-db}"
OW_USER="${OW_DB_USER:-open-wearables}"
OW_NAME="${OW_DB_NAME:-open-wearables}"

if [[ ! -f "$WGER_ENV" ]]; then
  echo "==> Writing $WGER_ENV"
  SECRET="$(python3 -c 'import secrets; print(secrets.token_urlsafe(48))')"
  sed \
    -e "s|^SECRET_KEY=.*|SECRET_KEY=${SECRET}|" \
    -e "s|^POSTGRES_USER=.*|POSTGRES_USER=${WG_USER}|" \
    -e "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=${WG_PASS}|" \
    -e "s|^POSTGRES_DB=.*|POSTGRES_DB=${WG_NAME}|" \
    -e "s|^PS_DATABASE_URI=.*|PS_DATABASE_URI=postgres://${WG_USER}:${WG_PASS}@wger-db:5432/${WG_NAME}|" \
    -e "s|^DJANGO_DB_DATABASE=.*|DJANGO_DB_DATABASE=${WG_NAME}|" \
    -e "s|^DJANGO_DB_USER=.*|DJANGO_DB_USER=${WG_USER}|" \
    -e "s|^DJANGO_DB_PASSWORD=.*|DJANGO_DB_PASSWORD=${WG_PASS}|" \
    -e "s|^TIME_ZONE=.*|TIME_ZONE=${TZ:-America/Toronto}|" \
    -e "s|^TZ=.*|TZ=${TZ:-America/Toronto}|" \
    "$WGER_EXAMPLE" > "$WGER_ENV"
else
  echo "==> Keeping existing $WGER_ENV"
fi

# --- Grafana datasource passwords (match root .env) ---
DS="$ROOT/grafana/provisioning/datasources/datasources.yaml"
echo "==> Syncing Grafana datasource passwords → $DS"
cat > "$DS" <<EOF
apiVersion: 1
datasources:
  - name: openwearables
    uid: openwearables
    type: postgres
    access: proxy
    url: ow-db:5432
    user: ${OW_USER}
    secureJsonData:
      password: ${OW_PASS}
    jsonData:
      database: ${OW_NAME}
      sslmode: disable
      postgresVersion: 1500
    isDefault: true
    editable: true

  - name: wger
    uid: wger
    type: postgres
    access: proxy
    url: wger-db:5432
    user: ${WG_USER}
    secureJsonData:
      password: ${WG_PASS}
    jsonData:
      database: ${WG_NAME}
      sslmode: disable
      postgresVersion: 1500
    editable: true
EOF

# Keep OW app DB password in sync if the file already exists
if [[ -f "$OW_ENV" ]] && [[ -n "${OW_DB_PASSWORD:-}" ]]; then
  if grep -q '^DB_PASSWORD=' "$OW_ENV"; then
    sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=${OW_DB_PASSWORD}|" "$OW_ENV"
  else
    echo "DB_PASSWORD=${OW_DB_PASSWORD}" >> "$OW_ENV"
  fi
fi

echo
echo "==> Next:"
echo "    1. Edit .env (passwords) and open-wearables/.env (SECRET_KEY, ADMIN_*)"
echo "    2. Match OW_DB_PASSWORD in .env with DB_PASSWORD in open-wearables/.env"
echo "    3. docker compose --profile full up -d --build"
echo "    4. Open http://localhost:3000  http://localhost:8080  http://localhost:3001"
echo "    5. Read docs/demo-walkthrough.md"
