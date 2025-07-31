@echo off
setlocal EnableDelayedExpansion

:: ------------------------------------------
:: UV-BASED UNIVERSAL PYTHON PROJECT STARTER
:: ------------------------------------------

echo [INFO] Checking for uv...

:: Step 1: Ensure uv is installed
where uv >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [INFO] uv not detected. Installing via PowerShell...
    powershell -ExecutionPolicy Bypass -Command "irm https://astral.sh/uv/install.ps1 | iex"

    :: TEMP PATCH: Add uv to PATH for this session
    set "PATH=%USERPROFILE%\.local\bin;%PATH%"

    :: Re-check if uv is now available
    where uv >nul 2>&1
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] uv still not detected after install. Exiting.
        pause
        exit /b 1
    )
)

:: Step 2: Display available Python versions and ask user
echo.
echo [INFO] Available installed Python versions:
uv python list --only-installed
echo.
set /p PYVER="Enter desired Python version (e.g. 3.12) or leave blank to use system Python: "

:: Step 3: Install specified version if entered
set "USE_PY="
if defined PYVER (
    echo [INFO] Installing Python version %PYVER% via uv...
    uv python install %PYVER%
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] uv python install failed. Exiting.
        pause
        exit /b 1
    )
    set "USE_PY=--python %PYVER%"
)

:: Step 4: Create or reuse .venv
echo [INFO] Creating virtual environment...
if exist .venv (
    echo [INFO] Reusing existing .venv
) else (
    uv venv %USE_PY%
)

:: Step 5: Install dependencies
if exist requirements.txt (
    echo [INFO] Installing dependencies from requirements.txt...
    uv pip sync requirements.txt
) else (
    echo [WARN] No requirements.txt found. Skipping dependency install.
)

:: Step 6: Ask user for main script
set /p MAINSCRIPT="Enter the main Python script to run (e.g. Manager.py): "

:: Step 7: Save settings to config.json
(
    echo {
    echo     "python_version": "!PYVER!",
    echo     "main_script": "!MAINSCRIPT!"
    echo }
) > config.json

:: Step 8: Run the main script using uv
echo [INFO] Launching script: !MAINSCRIPT!
uv run %USE_PY% -- python "!MAINSCRIPT%"

pause
