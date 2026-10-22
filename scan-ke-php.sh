#!/bin/bash
# Usage: ./scan-ke-php.sh <CIDR> <CategoryName>
CIDR="$1"
CAT="${2:-KE-PHP}"
OUT="/tmp/ke_php_$(date +%s).xml"

if [ -z "$CIDR" ]; then
    echo "Usage: $0 <CIDR> [Category]"
    exit 1
fi

echo "[*] Scanning $CIDR for PHP..."
# -Pn: Treat hosts as online
# --max-retries 1: Don't wait forever for dropped packets
# --host-timeout 30s: If a host takes more than 30s, skip it
sudo nmap -sS -Pn -p 80,443,8080,8443 --open -T4 \
    --max-retries 1 --host-timeout 30s \
    --script "http-php-version,http-cookie-flags,http-headers" \
    -oX "$OUT" "$CIDR"

echo "[*] Importing to IVRE..."
# Check if Nmap actually finished the file before importing
if grep -q "</nmaprun>" "$OUT"; then
    ivre scan2db -c "$CAT" -s "KE-Scan-$(date +%Y%m%d-%H%M)" -r "$OUT"
    ivre db2view nmap
    echo "[*] PHP results found in this batch:"
    ivre scancli --script http-php-version --limit 50
else
    echo "[!] Nmap scan was interrupted or failed. XML is incomplete. Skipping import."
fi