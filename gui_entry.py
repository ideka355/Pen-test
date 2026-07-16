"""PyInstaller entry point. Not run directly otherwise (use `pentest-tool-gui`).

PyInstaller executes its Analysis script as the top-level module, which
breaks pentest_tool/gui.py's relative imports (`from .engine import ...`)
since it'd have no parent package. Importing pentest_tool as a real package
from here keeps those imports intact.
"""
from pentest_tool.gui import main

if __name__ == "__main__":
    raise SystemExit(main())
