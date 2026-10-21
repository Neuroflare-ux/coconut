#!/usr/bin/env python3
import subprocess
import json
import re
import requests
from urllib3.exceptions import InsecureRequestWarning
from bs4 import BeautifulSoup

# Suppress HTTPS warnings
requests.packages.urllib3.disable_warnings(category=InsecureRequestWarning)

CATEGORIES = {
    "Finance": ["bank", "finance", "sacco", "credit", "loan", "investment", "pay", "wallet", "microfinance"],
    "Education": ["school", "university", "college", "academy", "learn", "exam", "student"],
    "Health": ["hospital", "clinic", "health", "medical", "doctor", "pharmacy"],
    "Government": ["gov", "county", "ministry", "public", "authority"],
}

def get_ivre_php_hosts():
    print("[*] Querying IVRE for PHP hosts...")
    result = subprocess.run(
        ["ivre", "scancli", "--script", "http-php-version", "--json"],
        capture_output=True, text=True
    )
    hosts = []
    for line in result.stdout.splitlines():
        try:
            data = json.loads(line)
            hosts.append(data["addr"])
        except json.JSONDecodeError:
            continue
    print(f"[*] Found {len(hosts)} hosts in IVRE.")
    return hosts

def classify_host(ip):
    for scheme in ["https", "http"]:
        try:
            url = f"{scheme}://{ip}"
            response = requests.get(url, timeout=5, verify=False)
            
            # Parse HTML
            soup = BeautifulSoup(response.text, "html.parser")
            
            # Get title
            title = soup.title.string.strip() if soup.title and soup.title.string else ""
            
            # Get body text (strip out script/style tags)
            for script in soup(["script", "style"]):
                script.decompose()
            body_text = soup.get_text(separator=' ', strip=True)
            
            # Combine title and body for keyword checking
            content = (title + " " + body_text).lower()
            
            category = "Uncategorized"
            found_keyword = ""
            for cat, keywords in CATEGORIES.items():
                for kw in keywords:
                    if kw in content:
                        category = cat
                        found_keyword = kw
                        break
                if found_keyword: break
                    
            print(f"[+] {ip} ({scheme}) | Category: {category} (matched '{found_keyword}') | Title: {title[:30]}...")
            
            # Print a snippet of the body text for context
            snippet = body_text[:80].replace('\n', ' ')
            print(f"    Snippet: {snippet}...")
            return
            
        except requests.RequestException:
            continue
    print(f"[-] {ip} | Could not fetch content")

if __name__ == "__main__":
    php_hosts = get_ivre_php_hosts()
    for ip in php_hosts:
        classify_host(ip)