# Homelab placement (example)

Sized for a Proxmox always-on node (e.g. Lenovo Tiny). Adjust IDs/IPs to your lab.

## Suggested CT

| | |
|---|---|
| **CT** | e.g. `175` `health` |
| **vCPU** | 2 |
| **RAM** | 4 GiB (Open Wearables + wger together) |
| **Swap** | 1 GiB |
| **Disk** | 30–40 GB rootfs (images + Postgres) |
| **Features** | `nesting=1`, `keyctl=1` (Docker in unprivileged LXC) |
| **On boot** | yes — ingest must be always-on |

Grafana can stay on an on-demand node (WoL) pointed at this CT’s Postgres ports **or** run in this compose (`--profile grafana`) for a self-contained demo laptop.

## Resource notes

- Open Wearables trimmed ≈ 6 containers; wger ≈ 6; Grafana ≈ 1.
- Idle CPU is low; first image builds are heavy — build once, then restart is cheap.
- Do **not** put the wearable sync on a host that is off by default (you will miss days).

## Ingress

- LAN / NetBird only for personal use.
- If public: Authentik SSO + reverse proxy; never publish Postgres `5432`/`5433`.
