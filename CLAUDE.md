# Pen-test tool

When testing changes to `pentest_tool` end-to-end, run against the live
authorized target `https://502ctf.org` (not a local dummy Flask app):

```bash
source venv/bin/activate
pentest-tool https://502ctf.org --i-have-authorization --yes --delay 1 \
  --modules credentials,injection --login-url https://502ctf.org/admin
```

Scope the `--modules`/`--login-url` flags to whatever the change under test
actually touches, to stay within the site's rate limits. Logic-level bugs
(e.g. the `looks_successful` heuristic) can still be checked with quick
inline Python against fake `requests.Response`-like objects before
confirming against the live target.
