# wger MCP (Cursor & Claude)

Use the official [`wger-mcp`](https://github.com/wger-project/mcp-server) server so an AI client can read/write your self-hosted wger over the REST API (routines, logs, weight, nutrition, …).

**Requires:** wger ≥ 2.6, Python ≥ 3.11, [`uv`](https://docs.astral.sh/uv/) (for `uvx`).

## 1) API key

In wger (web): **API access** → generate / copy the **API key** (DRF token). Treat it like a password.

## 2) Cursor

Edit `~/.cursor/mcp.json` (user-level) or the project `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "wger": {
      "command": "uvx",
      "args": ["wger-mcp", "--transport", "stdio"],
      "env": {
        "WGER_BASE_URL": "https://gym.<your-domain>.com",
        "WGER_API_KEY": "<paste-api-key>"
      }
    }
  }
}
```

Reload MCP in Cursor (or restart Cursor). First run downloads `wger-mcp` via `uvx`.

Optional: set `MCP_TOOLS` (see upstream README) if the full tool list is too large for the model.

## 3) Claude Desktop

Edit Claude’s MCP config:

- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Linux: `~/.config/Claude/claude_desktop_config.json`

```json
{
  "mcpServers": {
    "wger": {
      "command": "uvx",
      "args": ["wger-mcp", "--transport", "stdio"],
      "env": {
        "WGER_BASE_URL": "https://gym.<your-domain>.com",
        "WGER_API_KEY": "<paste-api-key>"
      }
    }
  }
}
```

Restart Claude Desktop.

## Notes

- **stdio + API key** is enough for a single-user homelab. OIDC / HTTP mode is for shared deployments (see upstream README).
- The MCP API key is **not** the Flutter JWT. Phone login still needs username/password, web handoff, or a long-lived refresh token.
- Point `WGER_BASE_URL` at the same public URL as `SITE_URL` (HTTPS via NPM), or at `http://<host-ip>:8080` on LAN.
