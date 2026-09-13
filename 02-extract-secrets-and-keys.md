# 2. Finding API Keys, Tokens, and Secrets with grep

This file gives you ready-to-use `grep` commands that scan files for common secret formats. It's the same kind of thing tools like `gitleaks` or `trufflehog` do under the hood, just in plain regex.

## The base command pattern

Almost everything here follows the same shape:

```bash
grep -roPn 'PATTERN' /path/to/scan
```

What each flag means:

| Flag | Meaning |
|---|---|
| `-r` | recursive: search every file in every subfolder |
| `-o` | only print the matching part, not the whole line |
| `-P` | use Perl-compatible regex (needed for lookarounds like `(?=` and `\K`) |
| `-n` | show the line number of each match |

Try every command below against the sample file first:

```bash
grep -roPn 'PATTERN' examples/sample.txt
```

---

## AWS Access Key ID

AWS access keys always start with a fixed prefix and are exactly 20 characters long, made of uppercase letters and digits.

```bash
grep -roPn '\b(AKIA|ASIA)[0-9A-Z]{16}\b' .
```

**How it works:** `(AKIA|ASIA)` matches either known prefix, then `[0-9A-Z]{16}` grabs the remaining 16 uppercase/digit characters, for 20 total.

## AWS Secret Access Key

Secret keys don't have a recognizable prefix, so we match them by shape near the word "secret":

```bash
grep -roPn '(?i)aws_secret_access_key\s*=\s*["\047]?([A-Za-z0-9/+=]{40})["\047]?' .
```

**How it works:** `(?i)` makes the match case-insensitive. We look for the literal label `aws_secret_access_key`, an `=`, an optional quote, then exactly 40 base64-style characters.

## Generic API key / token assignment

This one catches the common pattern of `api_key = "something"`, `token: "something"`, etc., no matter which service it belongs to:

```bash
grep -roPn '(?i)(api[_-]?key|secret|token|access[_-]?key|client[_-]?secret)["\047]?\s*[:=]\s*["\047][A-Za-z0-9_\-]{16,}["\047]' .
```

**How it works:** the first group matches common label words. Then it expects a `:` or `=`, then a quoted value of at least 16 letters, digits, underscores, or hyphens. That's long enough to filter out obviously fake short values.

## GitHub tokens

GitHub's newer tokens have very distinctive, fixed prefixes:

```bash
grep -roPn '\b(ghp|gho|ghu|ghs|ghr|github_pat)_[A-Za-z0-9_]{36,255}\b' .
```

| Prefix | Token type |
|---|---|
| `ghp_` | Personal access token |
| `gho_` | OAuth token |
| `ghu_` | User-to-server token |
| `ghs_` | Server-to-server token |
| `ghr_` | Refresh token |
| `github_pat_` | Fine-grained personal access token |

## Google API key

```bash
grep -roPn '\bAIza[0-9A-Za-z\-_]{35}\b' .
```

Google API keys always start with `AIza` and are 39 characters total.

## Slack tokens

```bash
grep -roPn '\bxox[baprs]-[A-Za-z0-9-]{10,72}\b' .
```

Slack tokens start with `xox`, followed by a letter identifying the token type (`b` = bot, `a` = app, `p` = user, `r` = refresh, `s` = workspace).

## JSON Web Tokens (JWT)

A JWT is always three base64url segments separated by dots.

```bash
grep -roPn '\bey[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b' .
```

**How it works:** JWTs almost always start with `ey` because that's the base64 encoding of `{"` (the start of the JSON header). The three `\.`-separated chunks are the header, payload, and signature.

## Private key files (PEM format)

Rather than the key content itself, this finds the header that marks a private key block. It's very reliable, with almost zero false positives:

```bash
grep -rnE '-----BEGIN (RSA |EC |OPENSSH |DSA |PGP )?PRIVATE KEY-----' .
```

## Generic "secret-looking" high-entropy strings

If you don't know the exact format, a useful trick is to look for long random-looking strings (a mix of upper, lower, and digits with no spaces), then review them by hand:

```bash
grep -roPn '\b(?=\S*[0-9])(?=\S*[a-z])(?=\S*[A-Z])[A-Za-z0-9_\-]{24,}\b' .
```

**How it works:** the three `(?=...)` lookaheads each require the match to contain at least one digit, one lowercase letter, and one uppercase letter somewhere inside it. That's a decent, though not perfect, signal that it's a random key rather than an English word.

---

## Putting it all together: a mini secret scanner

Save this as `scan-secrets.sh`:

```bash
#!/bin/bash
# Usage: ./scan-secrets.sh /path/to/scan

TARGET="${1:-.}"

echo "== AWS Access Keys =="
grep -roPn '\b(AKIA|ASIA)[0-9A-Z]{16}\b' "$TARGET"

echo "== GitHub Tokens =="
grep -roPn '\b(ghp|gho|ghu|ghs|ghr|github_pat)_[A-Za-z0-9_]{36,255}\b' "$TARGET"

echo "== Google API Keys =="
grep -roPn '\bAIza[0-9A-Za-z\-_]{35}\b' "$TARGET"

echo "== Slack Tokens =="
grep -roPn '\bxox[baprs]-[A-Za-z0-9-]{10,72}\b' "$TARGET"

echo "== JWTs =="
grep -roPn '\bey[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\b' "$TARGET"

echo "== Private Key Headers =="
grep -rnE '-----BEGIN (RSA |EC |OPENSSH |DSA |PGP )?PRIVATE KEY-----' "$TARGET"

echo "== Generic key/secret/token assignments =="
grep -roPn '(?i)(api[_-]?key|secret|token|access[_-]?key|client[_-]?secret)["\047]?\s*[:=]\s*["\047][A-Za-z0-9_\-]{16,}["\047]' "$TARGET"
```

Make it runnable and try it on the sample file:

```bash
chmod +x scan-secrets.sh
./scan-secrets.sh examples/sample.txt
```

## Handy add-ons

- **Only show unique matches:** pipe to `sort -u`
  ```bash
  grep -roPn '\bAKIA[0-9A-Z]{16}\b' . | sort -u
  ```
- **Limit to certain file types:**
  ```bash
  grep -roPn --include=\*.{env,py,js,json,yaml,yml} 'PATTERN' .
  ```
- **Skip common noisy folders:**
  ```bash
  grep -roPn --exclude-dir={.git,node_modules,venv} 'PATTERN' .
  ```

## A note on accuracy

Regex-based secret scanning is fast but not perfect:
- It **can't** tell if a matched key is still active or valid. That needs an API call, not a regex.
- It may produce **false positives** (test/dummy keys, example values in docs).
- It may miss secrets in **unusual formats** not covered by these patterns.

Treat these patterns as a fast first pass, then review matches by hand before taking action.

Next: **`03-extract-urls-ips-emails.md`** for pulling URLs, IPs, emails, and phone numbers.
