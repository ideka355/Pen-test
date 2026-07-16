# Pen-test tool

Domain recon + admin-access pentest pipeline: subdomains (crt.sh) -> DNS ->
nmap port scan -> gobuster content discovery -> web-app testing
(admin discovery, default creds, SQLi login bypass, exposed files, IDOR,
post-access crawl).

## Testing changes end-to-end

`port_scan` and `content_discovery` shell out to `nmap`/`gobuster` — real
external processes, not mocked. Prefer testing full-pipeline changes
against a local target you control rather than a live domain, since this
tool actively port-scans and brute-forces:

```bash
source venv/bin/activate
# spin up a local test app (Flask, http.server, etc.) bound to a port
# nmap's default top-1000 will actually hit, e.g. 80, 443, 8080
pentest-tool 127.0.0.1 --i-have-authorization --yes --top-ports 300 \
  --delay 0.05 --gobuster-delay 0.02
```

Logic-level bugs (e.g. `looks_successful`, hostname validation, XML/output
parsing) can be checked with quick inline Python against fake objects
before confirming against a real local target.

Passive-only stages (`subdomains`, `dns_resolve`) are safe to run against
real internet domains for testing — no requests ever touch the target:

```bash
pentest-tool example.com --i-have-authorization --yes --modules subdomains,dns_resolve
```

`crt.sh` is a known-flaky public service (occasional 502s/timeouts) — the
`subdomains` module must always fall back to the bare domain rather than
losing scope on a lookup failure; don't regress that.
