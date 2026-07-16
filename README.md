# Domain Recon & Admin-Access Pen-Test Tool

A Python CLI that takes a domain and runs an authorized recon-to-exploitation
pipeline against it:

1. **subdomains** — passive subdomain enumeration via certificate
   transparency logs (crt.sh). Never touches the target itself.
2. **dns_resolve** — resolves each discovered hostname to its IP(s).
3. **port_scan** — `nmap` service/version scan (TCP connect scan by
   default, no root required) against each resolved host.
4. **content_discovery** — `gobuster` directory/file brute-forcing against
   any HTTP(S) ports the port scan found.
5. **web_app** — the admin-access-focused web testing phase, run against
   each discovered web endpoint:
   - **recon** — server banner, tech fingerprint, `robots.txt`/`sitemap.xml`
   - **admin_discovery** — common admin/login path enumeration
   - **credentials** — a short list of well-known default credentials
     against discovered login forms (stops on first success)
   - **injection** — SQL-injection login-bypass payloads + raw SQL error
     disclosure
   - **exposure** — exposed config/backup/VCS files (`.env`, `.git/config`, ...)
   - **idor** — anonymous crawl + ID-probing to catch broken access control
     on `/thing/<id>` URLs
   - **post_access** — if a login succeeded, read-only (GET-only) crawl of
     what's reachable inside, flagging sensitive data and
     destructive-looking controls without ever invoking them

## ⚠️ Authorization

**Only run this against systems you own or have explicit written
permission to test.** This tool is *not* passive — `port_scan` and
`content_discovery`/`credentials`/`injection` actively probe the target.
Unauthorized use is illegal in most jurisdictions (e.g. the U.S. Computer
Fraud and Abuse Act).

The CLI requires `--i-have-authorization` and, unless `--yes` is passed, an
interactive confirmation where you type the exact target domain.

Built-in restraint:

- `credentials`/`injection` use small, published payload lists and stop on
  first apparent success per form — not brute-force tools
- every web-app-phase request goes through a shared rate limiter and a
  hard `--max-requests` budget
- `port_scan` defaults to the top 1000 ports (not all 65535) and an
  unprivileged TCP connect scan
- `--max-web-targets` caps how many discovered hosts/ports get the
  content-discovery/web-app treatment, so a domain with many subdomains
  doesn't silently balloon into an enormous scan

## Install

```bash
./install.sh
```

This creates a venv and installs the tool as the `pentest-tool` command.
`port_scan` and `content_discovery` shell out to external binaries that
aren't bundled — install them separately if `install.sh` flags them as
missing:

```bash
# Debian/Ubuntu
sudo apt install nmap gobuster
# macOS
brew install nmap gobuster
```

Everything else (`subdomains`, `dns_resolve`, `web_app`) works without
these — the tool degrades gracefully (reports "not available" findings for
the two stages) rather than failing if they're missing.

## Usage

```bash
source venv/bin/activate
pentest-tool example.com --i-have-authorization
```

You'll be asked to type the domain back to confirm authorization. To skip
that prompt (e.g. against a test target you control):

```bash
pentest-tool example.com --i-have-authorization --yes
```

Useful flags:

```
--modules subdomains,dns_resolve,port_scan,content_discovery,web_app  (default: all)
--web-app-modules recon,admin_discovery,credentials,injection,exposure,idor,post_access
--top-ports 1000              nmap: number of top ports to scan
--nmap-vuln-scripts           also run nmap's default+vuln NSE scripts (slower)
--nmap-timeout 300            per-host nmap timeout, seconds
--gobuster-delay 0.2          delay between gobuster requests, seconds
--gobuster-timeout 180        per-target gobuster timeout, seconds
--max-web-targets 10          cap on discovered (scheme,host,port) endpoints to test
--delay 0.5                   seconds between web-app-phase HTTP requests
--max-requests 500            hard cap on requests per web target in the web-app phase
--max-cred-attempts 15        default-credential attempts per login form
--explore-max-depth 2         post_access crawl depth
--explore-max-pages 40        post_access crawl page cap
--idor-crawl-max-depth 2      idor discovery crawl depth
--idor-crawl-max-pages 30     idor discovery crawl page cap
--idor-probes-per-template 5  max IDs tried per /thing/<id> template
--json-out report.json        write a machine-readable report
--no-tls-verify                for self-signed test targets only
```

Exit code is `2` if any HIGH/CRITICAL finding was reported, `0` otherwise —
handy for CI gating.

Only want the passive recon (no active scanning at all)?

```bash
pentest-tool example.com --i-have-authorization --modules subdomains,dns_resolve
```

## Project layout

```
pyproject.toml          packaging + `pentest-tool` console script
install.sh                one-shot venv setup + external-tool check
pentest_tool/
  cli.py                argument parsing, authorization gate
  engine.py               pipeline orchestration (recon stages + web-app phase)
  http_client.py         shared rate-limited/budgeted HTTP client (web-app phase)
  forms.py                login-form parsing shared by credentials/injection
  findings.py             Finding data model
  report.py               console + JSON reporting
  wordlists.py            loads data/*.txt
  modules/
    subdomains.py          crt.sh-based passive subdomain enumeration
    dns_resolve.py          hostname -> IP resolution
    port_scan.py             nmap wrapper
    content_discovery.py      gobuster wrapper
    recon.py
    admin_discovery.py
    credentials.py
    injection.py
    exposure.py
    idor.py
    post_access.py
  data/
    admin_paths.txt
    common_creds.txt
    sensitive_files.txt
    content_wordlist.txt
```

## Extending

Add a new wordlist entry to the relevant file in `pentest_tool/data/`, or
add a new module under `pentest_tool/modules/` that returns a
`list[Finding]` and wire it into `engine.py`.
