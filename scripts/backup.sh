#!/usr/bin/env bash
# Dump both Postgres databases. This is the durable asset.
#
# Usage: ./scripts/backup.sh [output-dir]
# Restore example:
#   gunzip -c backups/.../open-wearables.sql.gz | \
#     docker exec -i sh-ow-db psql -U open-wearables -d open-wearables
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/backups}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
DIR="$OUT/$STAMP"
mkdir -p "$DIR"

# Load root .env if present for credentials
if [[ -f "$ROOT/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$ROOT/.env"
  set +a
fi

OW_USER="${OW_DB_USER:-open-wearables}"
OW_DB="${OW_DB_NAME:-open-wearables}"
WG_USER="${WGER_DB_USER:-wger}"
WG_DB="${WGER_DB_NAME:-wger}"

echo "==> Backup $STAMP → $DIR"

if docker ps --format '{{.Names}}' | grep -qx sh-ow-db; then
  docker exec sh-ow-db pg_dump -U "$OW_USER" -d "$OW_DB" --no-owner --no-acl \
    | gzip -c > "$DIR/open-wearables.sql.gz"
  echo "    open-wearables.sql.gz ($(du -h "$DIR/open-wearables.sql.gz" | cut -f1))"
else
  echo "    skip open-wearables (sh-ow-db not running)"
fi

if docker ps --format '{{.Names}}' | grep -qx sh-wger-db; then
  docker exec sh-wger-db pg_dump -U "$WG_USER" -d "$WG_DB" --no-owner --no-acl \
    | gzip -c > "$DIR/wger.sql.gz"
  echo "    wger.sql.gz ($(du -h "$DIR/wger.sql.gz" | cut -f1))"
else
  echo "    skip wger (sh-wger-db not running)"
fi

if [[ -f "$ROOT/vendor/OPEN_WEARABLES_PIN.txt" ]]; then
  cp "$ROOT/vendor/OPEN_WEARABLES_PIN.txt" "$DIR/open-wearables.pin"
fi

echo "$STAMP" > "$DIR/TIMESTAMP"
echo "==> Done"
