# 3. Finding URLs, IP Addresses, Emails, and Phone Numbers

Same idea as file 2, but for the kind of data you'll want when mapping out infrastructure or cleaning up a dataset: web addresses, server addresses, contact info, and identifiers.

All commands follow the same pattern as before:

```bash
grep -roPn 'PATTERN' /path/to/scan
```

---

## URLs

```bash
grep -roPn 'https?://[A-Za-z0-9.\-]+(:[0-9]+)?(/[^\s"'"'"'<>]*)?' .
```

**How it works, piece by piece:**

| Piece | Meaning |
|---|---|
| `https?` | matches `http` or `https` (the `?` makes the `s` optional) |
| `://` | the literal separator |
| `[A-Za-z0-9.\-]+` | the domain name (letters, digits, dots, hyphens) |
| `(:[0-9]+)?` | an optional port number like `:8080` |
| `(/[^\s"'<>]*)?` | an optional path/query, stopping at whitespace or quotes |

**Simpler version** if you just want the domain, not the full path:

```bash
grep -roPn 'https?://\K[A-Za-z0-9.\-]+' .
```

`\K` tells grep "forget everything matched before this point," so only what comes after is printed. It's a clean alternative to a lookbehind.

## Email addresses

```bash
grep -roPn '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b' .
```

**How it works:** the local part (before `@`) allows letters, digits, and common symbols like `.`, `_`, `%`, `+`, `-`. The domain part requires at least one dot and a final segment of 2+ letters (the `.com`, `.org`, `.io`, etc).

## IPv4 addresses

A "quick and dirty" version (matches shape, not validity):

```bash
grep -roPn '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b' .
```

A **stricter** version that only matches valid octets (0–255), so it won't match nonsense like `999.999.999.999`:

```bash
grep -roPn '\b(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}\b' .
```

**How it works:** `(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])` matches any number from 0–255, broken into cases (250-255, 200-249, 100-199, 0-99). That whole group is then repeated three more times, each preceded by a literal dot.

## IPv6 addresses (basic form)

```bash
grep -roPn '\b([0-9A-Fa-f]{1,4}:){7}[0-9A-Fa-f]{1,4}\b' .
```

This covers the full, non-abbreviated form (`2001:0db8:0000:0000:0000:ff00:0042:8329`). IPv6 has shorthand rules (using `::` to skip repeated zero groups) that make a complete pattern quite long. For real production use, a dedicated library is usually more reliable than hand-written regex here.

## Private / internal IP ranges (useful for spotting internal addresses in logs)

```bash
grep -roPn '\b(10\.\d{1,3}\.\d{1,3}\.\d{1,3}|172\.(1[6-9]|2[0-9]|3[0-1])\.\d{1,3}\.\d{1,3}|192\.168\.\d{1,3}\.\d{1,3})\b' .
```

This matches the three reserved private ranges: `10.0.0.0/8`, `172.16.0.0/12`, and `192.168.0.0/16`.

## Phone numbers (general international-friendly pattern)

Phone formats vary a lot, so this pattern is intentionally flexible:

```bash
grep -roPn '\+?\d{1,3}[-.\s]?\(?\d{2,4}\)?[-.\s]?\d{3,4}[-.\s]?\d{3,4}\b' .
```

**How it works:** allows an optional leading `+` and country code, then groups of 2–4 digits separated by spaces, dots, or dashes, with optional parentheses around one group. This covers formats like `+977-9812345678`, `(555) 123-4567`, and `555.123.4567`.

## MAC addresses (handy for network logs)

```bash
grep -roPn '\b([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}\b' .
```

## Domain names only (no protocol required)

```bash
grep -roPn '\b(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}\b' .
```

Useful for pulling every domain mentioned in a file, even ones written without `http://` in front.

---

## Combined scanner script

Save as `scan-infra.sh`:

```bash
#!/bin/bash
TARGET="${1:-.}"

echo "== URLs =="
grep -roPn 'https?://[A-Za-z0-9.\-]+(:[0-9]+)?(/[^\s"'"'"'<>]*)?' "$TARGET"

echo "== Emails =="
grep -roPn '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b' "$TARGET"

echo "== IPv4 Addresses =="
grep -roPn '\b(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(\.(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}\b' "$TARGET"

echo "== Phone Numbers =="
grep -roPn '\+?\d{1,3}[-.\s]?\(?\d{2,4}\)?[-.\s]?\d{3,4}[-.\s]?\d{3,4}\b' "$TARGET"

echo "== MAC Addresses =="
grep -roPn '\b([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}\b' "$TARGET"
```

```bash
chmod +x scan-infra.sh
./scan-infra.sh examples/sample.txt
```

## A note on accuracy

The phone number and generic domain patterns above are intentionally loose, so they will sometimes catch things that aren't really phone numbers or domains (for example, a random run of digits, or a malformed IP like `999.999.999.999` might partially match). Always skim the output before trusting it. These patterns are a fast first pass, not a validator.

## Tips

- Add `| sort -u` to any command to remove duplicate matches.
- Add `| wc -l` to just count how many matches were found.
- Combine two searches with `grep -E 'pattern1|pattern2'` if you want two kinds of matches in one pass.

Next: **`04-custom-pattern-breakdown.md`**, a full worked example of pulling specific pieces out of a messy custom string.
