#!/bin/bash
# Usage: ./scan-ke-php.sh <CIDR> <CategoryName>
CIDR="$1"
CAT="${2:-KE-PHP}"
OUT="/tmp/ke_php_$(date +%s).xml"

echo "[*] Scanning $CIDR for PHP..."
# --min-rate 2000: Speeds up the SYN scan
# -T4: Faster timing template
# We drop -sV for speed, and just rely on the http-php-version script.
sudo nmap -sS -p 80,443,8080,8443 --open --min-rate 2000 -T4 \
    --script http-php-version \
    -oX "$OUT" "$CIDR"

echo "[*] Importing to IVRE..."
ivre scan2db -c "$CAT" -s "KE-Scan-$(date +%Y%m%d-%H%M)" -r "$OUT"
ivre db2view nmap

echo "[*] PHP results found in this batch:"
# Look specifically for the PHP script output
ivre scancli --script http-php-version --limit 50