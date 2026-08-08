# exercises-dataset (optional demo media)

Upstream: [hasaneyldrm/exercises-dataset](https://github.com/hasaneyldrm/exercises-dataset)

## What it is

~1,324 exercises with:

- metadata (equipment, body part, target muscles)
- step-by-step instructions in 10 languages
- 180×180 thumbnail + animation GIF per exercise

openGym already uses this set (local `./media` or jsDelivr CDN). **wger does not** — it syncs its own exercise library + images from `wger.de` (`SYNC_EXERCISES_CELERY` / `SYNC_EXERCISE_IMAGES_CELERY` in our `prod.env`).

## Where it fits this stack

| Layer | Role of this dataset |
|---|---|
| Open Wearables | None — sensor/time-series hub |
| wger | Overlaps purpose (exercise catalog). Do **not** replace wger’s sync with this unless you build a custom importer |
| Grafana | None |
| **Demo / coach UI** | Strong — GIFs make a live demo look finished |
| **Your archive** | Metadata JSON is fine to keep; media has separate terms |

So: **enrichment for demonstration**, not a fourth data plane next to wearables + gym logs.

## License (important for a public portfolio repo)

- **Code / JSON / instruction text** — MIT
- **`images/` + `videos/`** — © [Gym visual](https://gymvisual.com/), redistributed with permission at 180×180 only  
  Cloning the repo does **not** grant you a media license. Keep attribution  
  `© Gym visual — https://gymvisual.com/`. Read upstream `NOTICE.md` before shipping media in a public demo or product.

For a private homelab demo, following their attribution is the minimum. For a public GitHub “show-off” that *serves* the GIFs, confirm Gym visual’s terms cover your use or omit media and link to the dataset / CDN instead.

## Optional: pull for local browsing

```bash
./scripts/fetch-exercises-dataset.sh
# serves via: docker compose --profile media up -d
# then http://localhost:8090/
```

Media lives under `vendor/exercises-dataset/` (gitignored). Only the pin/README for this optional path is tracked.
