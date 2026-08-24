# Scrapling Runtime Operations

## Prerequisites

From the project root, install the optional integration:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements-scrapling.txt
.\.venv\Scripts\scrapling.exe install --force
```

`.venv/`, `.runtime/`, dan hasil crawl diabaikan oleh Git melalui `.gitignore`.

## Local stdio MCP

Use this launcher as the MCP command for a local client:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-scrapling-mcp-stdio.ps1
```

The launcher uses the project-local `.venv` and does not expose a network port.

## Local authenticated HTTP MCP

For a development-only local server:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\start-scrapling-mcp-http-dev.ps1
```

The helper:

- Binds to `127.0.0.1` only.
- Generates a random token once under ignored `.runtime/scrapling-mcp.token`.
- Injects the token through `SCRAPLING_MCP_AUTH_TOKEN`, never as a process argument.
- Enables `--allowed-host localhost:8000`.
- Must not be used as a public deployment mechanism.

Protect the `.runtime` directory. For production, do not use a project-local token file; inject `SCRAPLING_MCP_AUTH_TOKEN` from a secret manager and run `scripts/start-scrapling-mcp-http.ps1`.

## TLS reverse proxy

Use `deploy/Caddyfile.scrapling.example` only after replacing `mcp.example.com` with a real domain and configuring DNS/certificate issuance. Keep Scrapling itself on localhost:

```text
Client ── HTTPS/TLS ──> Caddy :443 ── localhost ──> Scrapling MCP :8000
```

Do not expose port `8000` publicly. Caddy's TLS does not replace MCP authentication or outbound SSRF controls.

## SSRF and egress

Scrapling tools can make outbound requests from the MCP host. Localhost binding protects the MCP endpoint, but it does not restrict destinations requested by a trusted local client. For network deployment, follow `deploy/scrapling-network-policy.example.md` and enforce:

- Target hostname allowlist.
- HTTPS-only policy.
- Private/metadata IP rejection after DNS resolution.
- Redirect, timeout, response-size, and concurrency limits.
- DNS-rebinding protection at the egress proxy/firewall.
- Least-privilege runtime identity.

Do not claim SSRF protection merely because the MCP endpoint has a bearer token.
