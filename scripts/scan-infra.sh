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
