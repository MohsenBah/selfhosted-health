# Nginx Proxy Manager (wger + PowerSync)

Compose already runs a **wger nginx sidecar** for static/media and `/ps/` (PowerSync). NPM is only the named HTTPS edge in front of `:8080`.

## Proxy host

| Field | Value |
|---|---|
| Domain | `gym.<your-domain>.com` |
| Scheme | `http` |
| Forward hostname / IP | `<host-ip>` (e.g. health CT) |
| Forward port | `8080` |
| Cache assets | Off |
| Block common exploits | On (optional) |
| **Websockets Support** | **On** (required for Flutter / PowerSync) |
| SSL | Let’s Encrypt (or your cert), Force SSL as preferred |

NPM must forward **all paths** on that host, including `/ps/`. Do **not** strip `/ps` or put Postgres on NPM.

## Optional Advanced (timeouts only)

After the host works with Websockets **On**, you may add:

```nginx
proxy_buffering off;
proxy_read_timeout 3600s;
proxy_send_timeout 3600s;
```

Avoid fragile Connection/Upgrade macros (`$http_connection`, etc.) in NPM Advanced — a bad snippet can break the whole SSL vhost (`tlsv1 unrecognized name` / default NPM page). Prefer the Websockets checkbox; use Advanced only for timeouts.

If HTTPS breaks after an Advanced edit: clear Advanced → Save → re-select SSL → Save (or disable/enable the host).

## wger `prod.env` (HTTPS)

```bash
SITE_URL=https://gym.<your-domain>.com
CSRF_TRUSTED_ORIGINS=https://gym.<your-domain>.com,http://<host-ip>:8080
X_FORWARDED_PROTO_HEADER_SET=True
USE_X_FORWARDED_HOST=True
NUMBER_OF_PROXIES=2
```

Then recreate web, restart nginx, flush Redis:

```bash
docker compose --profile gym up -d --force-recreate wger-web
docker restart sh-wger-nginx
docker compose exec wger-cache redis-cli FLUSHALL
```

## Smoke checks

```bash
curl -sS https://gym.<your-domain>.com/api/v2/version/
curl -sS https://gym.<your-domain>.com/ps/probes/liveness
```

Flutter server URL = `SITE_URL` (no path). Phone login uses JWT (local password, web handoff, or refresh token) — Authentik SSO on the website does not sync that password to the app.
