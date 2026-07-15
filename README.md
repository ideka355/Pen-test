# Website Admin-Access Pen-Test Tool

A Python CLI that helps you audit a website you're authorized to test for
common ways an attacker could reach admin access:

- **recon** — server banner, tech fingerprint, `robots.txt` / `sitemap.xml`
- **admin_discovery** — enumerates common admin/login paths and flags any
  with a live login form
- **credentials** — tries a short list of well-known default credentials
  against discovered login forms (stops on first success)
- **injection** — tests login forms for classic SQL-injection
  authentication bypass and raw SQL error disclosure
- **exposure** — checks for exposed config/backup/VCS files (`.env`,
  `.git/config`, `wp-config.php.bak`, ...) that can leak admin credentials
  directly
- **post_access** — if `credentials` or `injection` got in, reuses that
  authenticated session to crawl the admin area (GET-only, same-origin,
  depth/page-capped) and reports what's reachable: page titles, forms
  present, sensitive-data keywords (users/billing/API keys/...), and any
  controls whose label suggests a destructive action (delete/remove/drop).
  It never submits a form or clicks a button — those are reported by
  label only, so you can see the blast radius without touching data.

## ⚠️ Authorization

**Only run this against systems you own or have explicit written
permission to test.** Unauthorized access attempts are illegal in most
jurisdictions (e.g. the U.S. Computer Fraud and Abuse Act). The CLI
requires `--i-have-authorization` and, unless `--yes` is passed, an
interactive confirmation where you type the exact target URL.

The tool is deliberately conservative:

- a small, published default-credential list only — not a brute-force /
  credential-stuffing tool
- a handful of non-destructive SQLi auth-bypass payloads — no data
  extraction, no writes
- every request goes through a shared rate limiter and a hard
  `--max-requests` cap
- credential/injection testing stops immediately on the first apparent
  success per form

## Install

```bash
pip install -r requirements.txt
```

## Usage

```bash
python -m pentest_tool https://target.example --i-have-authorization
```

You'll be asked to type the target URL back to confirm authorization. To
skip that prompt (e.g. in CI against a test target you control):

```bash
python -m pentest_tool https://target.example --i-have-authorization --yes
```

Useful flags:

```
--modules recon,admin_discovery,credentials,injection,exposure,post_access   (default: all)
--delay 0.5               seconds between requests
--max-requests 500         hard cap on total requests for the scan
--max-cred-attempts 15     default-credential attempts per login form
--explore-max-depth 2       link-follow depth for post_access crawling
--explore-max-pages 40      page cap for post_access crawling
--json-out report.json     write a machine-readable report
--no-tls-verify             for self-signed test targets only
```

Exit code is `2` if any HIGH/CRITICAL finding was reported, `0` otherwise —
handy for CI gating.

## Project layout

```
pentest_tool/
  cli.py              argument parsing, orchestration, authorization gate
  http_client.py       shared rate-limited/budgeted HTTP client
  forms.py              login-form parsing shared by credentials/injection
  findings.py           Finding data model
  report.py             console + JSON reporting
  wordlists.py          loads data/*.txt
  modules/
    recon.py
    admin_discovery.py
    credentials.py
    injection.py
    exposure.py
    post_access.py
data/
  admin_paths.txt
  common_creds.txt
  sensitive_files.txt
```

## Extending

Add a new wordlist entry to the relevant file in `data/`, or add a new
module under `pentest_tool/modules/` that returns a `list[Finding]` and
wire it into `cli.py`'s `requested_modules` handling.
