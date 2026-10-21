#!/bin/bash
# Usage: ./scan-ke-php.sh <CIDR> <CategoryName>
CIDR="$1"
CAT="${2:-KE-PHP}"
OUT="/tmp/ke_php_$(date +%s).xml"

echo "[*] Scanning $CIDR for PHP..."
sudo nmap -sS -sV --script http-php-version -p 80,443,8080,8443 -oX "$OUT" "$CIDR"

echo "[*] Importing to IVRE..."
ivre scan2db -c "$CAT" -s "KE-Scan-$(date +%Y%m%d)" -r "$OUT"
ivre db2view nmap

echo "[*] PHP results in this batch:"
ivre scancli --script http-php-version --limit 20