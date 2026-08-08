#!/usr/bin/env bash
# Optional: clone exercises-dataset for local demo media (GIFs/thumbnails).
# See docs/exercises-dataset.md for license caveats (Gym visual media terms).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO="${EXERCISES_REPO:-https://github.com/hasaneyldrm/exercises-dataset.git}"
REF="${EXERCISES_REF:-main}"
DEST="$ROOT/vendor/exercises-dataset"

echo "==> exercises-dataset → $DEST ($REF)"
if [[ ! -d "$DEST/.git" ]]; then
  mkdir -p "$ROOT/vendor"
  git clone --depth 1 --branch "$REF" "$REPO" "$DEST"
else
  git -C "$DEST" fetch --depth 1 origin "$REF"
  git -C "$DEST" checkout -q FETCH_HEAD || git -C "$DEST" checkout -q "$REF"
fi

PIN="$(git -C "$DEST" rev-parse --short HEAD)"
echo "$PIN" > "$ROOT/vendor/EXERCISES_DATASET_PIN.txt"
echo "    pinned at $PIN"
echo
echo "    Attribution required for media: © Gym visual — https://gymvisual.com/"
echo "    Start static browser:  docker compose --profile media up -d"
echo "    Open:                  http://localhost:8090/"
