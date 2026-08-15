# Homelab placement (example)

Sized for a Proxmox always-on LXC (Docker in unprivileged CT). Adjust IDs/IPs to your lab.

## Suggested CT (apps + local DBs)

| | Comfortable | Lean (after stable) |
|---|---|---|
| **vCPU** | 2 | 2 |
| **RAM** | **4 GiB** | **3 GiB** |
| **Swap** | **1 GiB** | **1 GiB** |
| **Disk** | 20–25 GB rootfs (images + Postgres volumes) | same |
| **Features** | `nesting=1`, `keyctl=1` | same |
| **On boot** | yes — ingest must be always-on | same |

Prefer **4 GiB** for first bring-up (`--profile wearables` + `--profile gym`). Drop to **3 GiB** only after memory looks calm under sync + a wger session. **2 GiB** is too tight and often OOMs or fails the wger healthcheck.

## Grafana

| Mode | When |
|---|---|
| **Existing Grafana** (recommended for a real lab) | Point datasources at this CT’s `:5432` / `:5433` — see [existing-grafana.md](existing-grafana.md). Run Grafana on an on-demand node (WoL) if you do not need dashboards 24/7. |
| **Compose profile `grafana`** | Laptop / single-box demo (`--profile full`). |

Do **not** put the wearable sync stack on a host that is off by default.

## Resource notes

- Open Wearables trimmed ≈ 6 containers; wger ≈ 6 (including nginx sidecar).
- Idle CPU is low; first image builds are heavy — build once, then restart is cheap.
- A separate shared “DB only” CT is optional and usually not worth it for two small Postgres instances.

## Ingress

- LAN reverse proxy (e.g. **Nginx Proxy Manager**) to UI / API / wger HTTP only — see README “Nginx Proxy Manager”.
- Compose still needs the **wger nginx** container for static/media; NPM sits in front of `:8080`.
- Never publish Postgres `5432`/`5433` on the public proxy.
