#!/usr/bin/env bash
# One-time setup: creates a venv (works around Debian/Ubuntu's
# "externally-managed-environment" pip restriction) and installs the tool
# into it as the `pentest-tool` command. Also checks for the external
# nmap/gobuster binaries the recon pipeline shells out to.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -d venv ]; then
    echo "Creating virtual environment in ./venv ..."
    python3 -m venv venv
fi

# shellcheck disable=SC1091
source venv/bin/activate
pip install -q --upgrade pip
pip install -q -e .

echo ""
missing=()
command -v nmap >/dev/null 2>&1 || missing+=("nmap")
command -v gobuster >/dev/null 2>&1 || missing+=("gobuster")

if [ ${#missing[@]} -gt 0 ]; then
    echo "NOTE: the following external tools are not on PATH: ${missing[*]}"
    echo "  Debian/Ubuntu: sudo apt install ${missing[*]}"
    echo "  macOS:         brew install ${missing[*]}"
    echo "The port_scan / content_discovery stages will report as unavailable until installed."
    echo ""
fi

echo "Setup complete."
echo ""
echo "In every new terminal, activate the environment first:"
echo "  source venv/bin/activate"
echo ""
echo "Then run the tool:"
echo "  pentest-tool example.com --i-have-authorization"
