# Kenya PHP OSINT Scanner

This project automates the discovery of PHP web servers in specific geographic regions (starting with Kenya) and imports the results into an IVRE instance for analysis and visualization.

## Prerequisites
- Fedora Linux (or similar)
- MongoDB (`mongod`)
- IVRE (installed via source)
- Nmap
- Python 3

## Setup
1. Clone the repository.
2. Ensure IVRE is running (`ivre httpd --bind 127.0.0.1 --port 8090`).
3. Extract target IP ranges into `kenya_ips.txt`.

## Usage
Run the scanner script against a specific CIDR block:

```bash
sudo ./scan-ke-php.sh 41.57.96.0/24 KE-TEST
