# Demo walkthrough (~5 minutes)

Goal: show “vendor-neutral health store + gym logger + joined dashboard” without claiming clinical accuracy.

## Prep

```bash
./scripts/bootstrap.sh
cp .env.example .env   # set GRAFANA_ADMIN_PASSWORD, etc.
docker compose --profile full up -d --build
```

Wait until:

- http://localhost:3000 — Open Wearables portal
- http://localhost:8080 — wger (**nginx**; not raw gunicorn :8000)
- http://localhost:3001 — Grafana

## Script

1. **Pitch (30s)**  
   “Wearables sync into a self-hosted hub. Gym logging is a separate mature app. Grafana joins both. Nightly dumps mean we own the data even if a project dies.”

2. **Open Wearables (90s)**  
   - Log in with `ADMIN_EMAIL` / `ADMIN_PASSWORD` from `open-wearables/.env`  
   - Show developer portal / API docs at `:8000/docs`  
   - Mention providers: Garmin, Polar, Oura, HealthKit SDK — connect whichever you have for the live demo  
   - Point at “data stays in our Postgres”

3. **wger (90s)**  
   - Create/login user  
   - Log a short workout (squat / press)  
   - Mention Flutter app for phone use  
   - Explicitly: no wearable sync required for the gym path

4. **Grafana (90s)**  
   - Open provisioned datasources (`openwearables`, `wger`)  
   - Open “Health stack overview” dashboard  
   - Show SQL panels: last workouts from wger + recent series from Open Wearables (or empty-state honesty if no wearable connected yet)

5. **Insurance (30s)**  
   ```bash
   ./scripts/backup.sh ./backups
   ls -lh ./backups
   ```  
   “This dump is the asset. Apps are replaceable.”

## Honest limitations 

- Open Wearables is young; pin commits for demos.
- wger health-platform sync (Health Connect / Apple Health) is in progress upstream — not relied on here.
- Google Health Connect has no server API; phone → Open Wearables SDK is the Apple/Android path.
