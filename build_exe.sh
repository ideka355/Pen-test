#!/usr/bin/env bash
# Build a native single-file executable for the current OS (Linux/macOS).
# For a Windows .exe, run build_exe.bat from Windows Python instead --
# PyInstaller can't cross-compile.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -d venv ]; then
    python3 -m venv venv
fi

# shellcheck disable=SC1091
source venv/bin/activate
pip install -q --upgrade pip
pip install -q -e .
pip install -q pyinstaller

pyinstaller --noconfirm pentest_tool_gui.spec

echo ""
echo "Done. Executable is at dist/PentestTool"
