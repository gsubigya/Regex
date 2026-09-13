# Understanding Regex

A beginner-friendly repository for learning regular expressions (regex), and then using that skill for a practical security purpose: finding API keys, tokens, secrets, URLs, IPs, emails, and custom patterns inside files using grep.

The writing here is kept plain and simple on purpose. Every pattern comes with an example and an explanation of why it works, not just that it works.

## What's inside

| File | What you'll learn |
|---|---|
| [`01-regex-basics.md`](01-regex-basics.md) | What regex is, and how to build patterns step by step, from your first match to groups and lookarounds |
| [`02-extract-secrets-and-keys.md`](02-extract-secrets-and-keys.md) | Ready-to-use grep patterns to find API keys, tokens, secrets, and credentials in any file or folder |
| [`03-extract-urls-ips-emails.md`](03-extract-urls-ips-emails.md) | Patterns for pulling URLs, IP addresses, emails, and phone numbers out of any text |
| [`04-custom-pattern-breakdown.md`](04-custom-pattern-breakdown.md) | A worked example that extracts specific pieces, like a name or country, out of a messy mixed string |
| [`05-detect-apk-malware-indicators.md`](05-detect-apk-malware-indicators.md) | Static analysis patterns for APKs: risky permissions, hardcoded C2 URLs/IPs, dynamic code loading APIs, encoded payload blobs, and NOP sled style hex signatures |
| [`examples/sample.txt`](examples/sample.txt) | A safe, fake test file with dummy tokens, URLs, and IPs so you can practice every command in files 2 and 3 without touching real data |
| [`examples/fake_manifest.xml`](examples/fake_manifest.xml) and [`examples/fake_decompiled_strings.txt`](examples/fake_decompiled_strings.txt) | Safe, fake APK analysis test data for file 5 |

## Suggested order

1. Read `01-regex-basics.md` first, even if you've seen regex before. It sets up the vocabulary the rest of the repo uses.
2. Try every command in this repo against the `examples/` files before you ever run it against real files.
3. Move to `02` and `03` once the basics feel comfortable.
4. Read `04` to see how the pieces combine into a custom pattern.
5. Finish with `05` for a security focused look at static APK triage.

## A note on responsible use

The patterns in this repo are meant for:
- Scanning your own code, logs, and configs for accidentally committed secrets
- Learning regex through realistic, practical examples
- Security research and malware/APK triage on samples and systems you own or are authorized to test

Never use these patterns to search for or extract secrets, credentials, or personal data that you are not authorized to access. Only run the APK analysis patterns in file samples you're authorized to analyze.
