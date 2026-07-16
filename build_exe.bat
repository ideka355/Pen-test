@echo off
REM Build PentestTool.exe. Run this from Windows (PowerShell/cmd), with a
REM Windows-native Python on PATH -- NOT from inside WSL, since PyInstaller
REM builds for whatever OS it's running on and can't cross-compile.
setlocal

if not exist venv-win (
    echo Creating virtual environment in .\venv-win ...
    python -m venv venv-win
)

call venv-win\Scripts\activate.bat
pip install -q --upgrade pip
pip install -q -e .
pip install -q pyinstaller

pyinstaller --noconfirm pentest_tool_gui.spec

echo.
echo Done. Executable is at dist\PentestTool.exe
