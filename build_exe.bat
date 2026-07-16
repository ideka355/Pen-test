@echo off
REM Build PentestTool.exe. Run this from Windows (PowerShell/cmd), with a
REM Windows-native Python on PATH -- NOT from inside WSL, since PyInstaller
REM builds for whatever OS it's running on and can't cross-compile.
REM Run from a normal (non-Administrator) terminal, in a normal folder --
REM PyInstaller refuses to run elevated or from inside C:\Windows\System32.
setlocal

if not exist venv-win (
    echo Creating virtual environment in .\venv-win ...
    python -m venv venv-win
    if errorlevel 1 goto :error
)

call venv-win\Scripts\activate.bat

pip install -q -e .
if errorlevel 1 goto :error

pip install -q pyinstaller
if errorlevel 1 goto :error

pyinstaller --noconfirm pentest_tool_gui.spec
if errorlevel 1 goto :error

if not exist dist\PentestTool.exe (
    echo.
    echo Build reported success but dist\PentestTool.exe was not created.
    goto :error
)

echo.
echo Done. Executable is at dist\PentestTool.exe
exit /b 0

:error
echo.
echo Build FAILED -- see the errors above.
echo Common causes: running this from an Administrator PowerShell/cmd, or
echo from inside C:\Windows\System32 (PyInstaller refuses both). Use a
echo normal, non-admin terminal in a regular folder like %USERPROFILE%.
exit /b 1
