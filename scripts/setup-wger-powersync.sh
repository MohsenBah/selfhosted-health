#!/usr/bin/env bash
# One-time (idempotent) PowerSync bootstrap for Flutter.
# Prerequisites: gym profile up, JWT_* set in wger/config/prod.env, SITE_URL correct.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ ! -f wger/config/prod.env ]]; then
  echo "Missing wger/config/prod.env — run ./scripts/bootstrap.sh first" >&2
  exit 1
fi

if ! grep -q '^JWT_PRIVATE_KEY=.\+' wger/config/prod.env || ! grep -q '^JWT_PUBLIC_KEY=.\+' wger/config/prod.env; then
  echo "==> Generate JWT keys and paste into wger/config/prod.env (no quotes), then recreate wger-web:"
  echo "    docker compose --profile gym exec wger-web python3 manage.py generate-jwt-keys"
  echo "    # edit prod.env, then:"
  echo "    docker compose --profile gym up -d --force-recreate wger-web wger-powersync wger-nginx"
  exit 1
fi

echo "==> Ensure PowerSync storage role/schema"
docker compose --profile gym exec wger-web python3 manage.py setup-powersync-storage

echo "==> Restart PowerSync + nginx"
docker compose --profile gym up -d wger-powersync
docker compose --profile gym restart wger-nginx

echo "==> Probe /ps/ (expect JSON error about path is OK — means proxy works)"
curl -sS -o /tmp/wger-ps.json -w "%{http_code}\n" "http://127.0.0.1:${WGER_HTTP_PORT:-8080}/ps/" || true
head -c 200 /tmp/wger-ps.json 2>/dev/null; echo

echo "==> Done. In Flutter set server URL to your public SITE_URL (https://gym.<your-domain>.com)."
echo "    NPM must forward the whole host including /ps/ to :8080."
