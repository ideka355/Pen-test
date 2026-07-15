#!/usr/bin/env bash
# One-time setup: creates a venv (works around Debian/Ubuntu's
# "externally-managed-environment" pip restriction) and installs the tool
# into it as the `pentest-tool` command.
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
echo "Setup complete."
echo ""
echo "In every new terminal, activate the environment first:"
echo "  source venv/bin/activate"
echo ""
echo "Then run the tool:"
echo "  pentest-tool https://your-site.example --i-have-authorization"
