@echo off
setlocal EnableDelayedExpansion

:: Pass all arguments to the main logic if we've been restarted
if /i "%~1"=="--restarted" (
    shift
    goto main_logic
)

:: ==========================================
:: INITIAL UV CHECK & RESTART
:: ==========================================
:: Force ANSI escape characters for colors for this initial check
set "ESC="
set "RED=%ESC%[31m"
set "GREEN=%ESC%[32m"
set "YELLOW=%ESC%[33m"
set "RESET=%ESC%[0m"

where uv >nul 2>&1
if %ERRORLEVEL% EQU 0 goto main_logic

echo %YELLOW%[INFO]%RESET% 'uv' not found. Attempting to install...
where pwsh >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    pwsh -NoLogo -NoProfile -Command "irm https://astral.sh/uv/install.ps1 | iex"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://astral.sh/uv/install.ps1 | iex"
)
if %ERRORLEVEL% NEQ 0 (
    echo %RED%[ERROR]%RESET% UV installation failed. Please install it manually:
    echo     https://docs.astral.sh/uv/getting-started/installation/
    pause
    exit /b 1
)

echo %GREEN%[OK]%RESET% 'uv' installed.
:: Permanently add uv to the user PATH. The user may need to restart shells for it to take effect everywhere.
echo %YELLOW%[INFO]%RESET% Adding 'uv' to your user PATH. You may need to restart your terminal for it to be available everywhere.
setx PATH "%USERPROFILE%\.local\bin;%PATH%" >nul

echo %YELLOW%[INFO]%RESET% Restarting script in a new terminal to use the updated PATH...
start "Setup-UV" cmd /c "%~f0 --restarted %*"
exit /b 0


:main_logic
:: ==========================================
:: UV-BASED UNIVERSAL PYTHON PROJECT STARTER
:: ==========================================

:: Force ANSI escape characters for colors
set "ESC="
set "RED=%ESC%[31m"
set "GREEN=%ESC%[32m"
set "YELLOW=%ESC%[33m"
set "BLUE=%ESC%[34m"
set "RESET=%ESC%[0m"

:: Default values
set "PYVER="
set "USE_PY="
set "MAINSCRIPT="
set "CONFIGFILE="

:: Detect execution mode
if /i "%~1"=="auto" goto auto_mode
if /i "%~1"=="menu" goto menu_mode
if /i "%~1"=="toggle" goto toggle_mode

echo %BLUE%========================================%RESET%
echo %BLUE%   UV Project Setup - Choose Mode%RESET%
echo %BLUE%========================================%RESET%
echo.
echo [1] Auto Mode    - Run full setup automatically
echo [2] Menu Mode    - Step-by-step guided setup
echo [3] Toggle Mode  - Select tasks to toggle
echo.
set /p "CHOICE=Select mode (1-3): "
if "%CHOICE%"=="1" goto auto_mode
if "%CHOICE%"=="2" goto menu_mode
if "%CHOICE%"=="3" goto toggle_mode
exit /b 0


:: ==========================================
:: STATUS FUNCTION
:: ==========================================
:show_status
cls
echo %BLUE%========================================%RESET%
echo %BLUE%   UV Python Project Setup - Status%RESET%
echo %BLUE%========================================%RESET%

:: uv check
where uv >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    for /f "tokens=*" %%v in ('uv --version') do set "UVVER=%%v"
    echo %GREEN%[OK]%RESET% uv: installed (!UVVER!)
) else (
    echo %RED%[MISSING]%RESET% uv not found
)

:: system python check
where python >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    python --version >"%TEMP%\pyver.tmp" 2>&1
    for /f "usebackq tokens=*" %%v in ("%TEMP%\pyver.tmp") do set "SYS_PY=%%v"
    del "%TEMP%\pyver.tmp"
    echo %GREEN%[OK]%RESET% System Python: !SYS_PY!
) else (
    echo %RED%[MISSING]%RESET% System Python not found in PATH
)

:: uv python versions
echo.
echo %YELLOW%[INFO]%RESET% UV-managed Python versions:
uv python list --only-installed 2>nul
if %ERRORLEVEL% NEQ 0 echo %RED%[ERROR]%RESET% uv python list failed.

:: venv check
if defined VIRTUAL_ENV (
    echo %GREEN%[OK]%RESET% venv: active (!VIRTUAL_ENV!)
) else if exist .venv (
    echo %GREEN%[OK]%RESET% venv: found (.venv)
    if exist .venv\Scripts\python.exe (
        .venv\Scripts\python.exe --version >"%TEMP%\venvpy.tmp" 2>&1
        for /f "usebackq tokens=*" %%v in ("%TEMP%\venvpy.tmp") do set "VENV_PY=%%v"
        del "%TEMP%\venvpy.tmp"
        echo %GREEN%[OK]%RESET% Active venv Python: !VENV_PY!
    )
) else (
    echo %YELLOW%[WARN]%RESET% venv: not found
)

:: dependency check
if exist requirements.lock (
    echo %GREEN%[OK]%RESET% deps: requirements.lock
    set "DEPFILE=requirements.lock"
) else if exist requirements.txt (
    echo %GREEN%[OK]%RESET% deps: requirements.txt
    set "DEPFILE=requirements.txt"
) else if exist pyproject.toml (
    echo %GREEN%[OK]%RESET% deps: pyproject.toml
    set "DEPFILE=pyproject.toml"
) else (
    echo %YELLOW%[WARN]%RESET% deps: none found
    set "DEPFILE="
)

:: config check
if exist config.json (
    set "CONFIGFILE=config.json"
) else if exist uv_project_config.json (
    set "CONFIGFILE=uv_project_config.json"
)

if defined CONFIGFILE (
    echo %GREEN%[OK]%RESET% config: %CONFIGFILE%
    for /f "delims=" %%A in ('powershell -NoProfile -Command "(Get-Content '%CONFIGFILE%' | ConvertFrom-Json).python_version" 2^>nul') do set "CFG_PY=%%A"
    for /f "delims=" %%A in ('powershell -NoProfile -Command "(Get-Content '%CONFIGFILE%' | ConvertFrom-Json).main_script" 2^>nul') do set "CFG_SCRIPT=%%A"
    echo %YELLOW%[INFO]%RESET% saved python=!CFG_PY!, script=!CFG_SCRIPT!
) else (
    echo %YELLOW%[WARN]%RESET% config: none found
)

echo.
goto :eof


:: ==========================================
:: CORE FUNCTIONS
:: ==========================================
:handle_python_version
echo %YELLOW%[INFO]%RESET% Python version setup...
uv python list --only-installed
set /p "PYVER=Enter Python version to install (blank=skip): "
if defined PYVER (
    uv python install %PYVER%
    if %ERRORLEVEL% NEQ 0 (
        echo %RED%[ERROR]%RESET% Failed to install Python %PYVER%.
        pause
        goto :eof
    )
    set "USE_PY=--python %PYVER%"
)
goto :eof

:handle_virtual_environment
if defined VIRTUAL_ENV (
    echo %GREEN%[OK]%RESET% Virtual environment already active.
    goto :eof
)
echo %YELLOW%[INFO]%RESET% Virtual environment setup...
if exist .venv (
    echo %GREEN%[OK]%RESET% Reusing existing .venv
) else (
    uv venv %USE_PY%
)
goto :eof

:handle_dependencies
if defined DEPFILE (
    echo %YELLOW%[INFO]%RESET% Installing dependencies from %DEPFILE%...
    if /i "%DEPFILE%"=="requirements.lock" (
        uv pip sync "%DEPFILE%"
    ) else if /i "%DEPFILE%"=="requirements.txt" (
        uv pip install -r "%DEPFILE%"
    ) else if /i "%DEPFILE%"=="pyproject.toml" (
        uv sync
    )
) else (
    echo %YELLOW%[WARN]%RESET% No dependency file to install.
)
goto :eof

:handle_main_script
set /p "MAINSCRIPT=Enter main script (default=main.py): "
if not defined MAINSCRIPT set "MAINSCRIPT=main.py"
if not exist "!MAINSCRIPT!" (
    echo %YELLOW%[WARN]%RESET% '!MAINSCRIPT!' not found. Creating placeholder...
    echo print("Hello from !MAINSCRIPT!") > "!MAINSCRIPT!"
)
goto :eof

:save_config
(
    echo {
    echo     "python_version": "!PYVER!",
    echo     "main_script": "!MAINSCRIPT!"
    echo }
) > config.json
goto :eof

:load_config
if exist config.json (
    for /f "delims=" %%A in ('powershell -NoProfile -Command "(Get-Content config.json | ConvertFrom-Json).python_version" 2^>nul') do set "PYVER=%%A"
    for /f "delims=" %%A in ('powershell -NoProfile -Command "(Get-Content config.json | ConvertFrom-Json).main_script" 2^>nul') do set "MAINSCRIPT=%%A"
    if defined PYVER set "USE_PY=--python !PYVER!"
    echo %YELLOW%[INFO]%RESET% Loaded config: python=!PYVER!, script=!MAINSCRIPT!
)
goto :eof

:: ==========================================
:: AUTO MODE
:: ==========================================
:auto_mode
if not exist "requirements.txt" if not exist "pyproject.toml" if not exist "main.py" (
    echo %YELLOW%[INFO]%RESET% First run detected. Initializing a default project...
    uv init
)
call :show_status
call :load_config
if not defined PYVER call :handle_python_version
if not exist .venv call :handle_virtual_environment
call :handle_dependencies
if not defined MAINSCRIPT call :handle_main_script
call :save_config
echo %GREEN%[OK]%RESET% Launching !MAINSCRIPT!...
uv run %USE_PY% -- "!MAINSCRIPT!"
pause
exit /b 0



:: ==========================================
:: MENU MODE
:: ==========================================
:menu_mode
:menu_loop
call :show_status
echo [1] Python Version Setup
echo [2] Virtual Environment
echo [3] Install Dependencies
echo [4] Select Main Script
echo [5] Git Initialization
echo [6] Print Summary
echo [7] VS Code Launch
echo [8] Activate Venv in New Terminal
echo [Q] Quit
echo.
set /p "CHOICE=Select option: "

if /i "%CHOICE%"=="1" call :handle_python_version
if /i "%CHOICE%"=="2" call :handle_virtual_environment
if /i "%CHOICE%"=="3" call :handle_dependencies
if /i "%CHOICE%"=="4" call :handle_main_script
if /i "%CHOICE%"=="5" call :handle_git_init
if /i "%CHOICE%"=="6" call :print_summary
if /i "%CHOICE%"=="7" call :handle_vscode
if /i "%CHOICE%"=="8" call :activate_venv
if /i "%CHOICE%"=="Q" exit /b 0

goto menu_loop


:: ==========================================
:: TOGGLE MODE
:: ==========================================
:toggle_mode
set "DO_PY=0"
set "DO_VENV=0"
set "DO_DEPS=0"
set "DO_SCRIPT=0"
set "DO_GIT=0"
set "DO_SUMMARY=0"
set "DO_VSCODE=0"
set "DO_ACTIVATE=0"

:toggle_loop
call :show_status
echo [1] Python Version Setup    : !DO_PY!
echo [2] Virtual Environment     : !DO_VENV!
echo [3] Install Dependencies    : !DO_DEPS!
echo [4] Select Main Script      : !DO_SCRIPT!
echo [5] Git Initialization      : !DO_GIT!
echo [6] Print Summary           : !DO_SUMMARY!
echo [7] VS Code Launch          : !DO_VSCODE!
echo [8] Activate Venv           : !DO_ACTIVATE!
echo.
echo [R] Run selected actions
echo [Q] Quit
echo.
set /p "CHOICE=Toggle option (1-8), R=Run, Q=Quit: "

if /i "!CHOICE!"=="1" if !DO_PY! EQU 0 (set DO_PY=1) else (set DO_PY=0) & goto toggle_loop
if /i "!CHOICE!"=="2" if !DO_VENV! EQU 0 (set DO_VENV=1) else (set DO_VENV=0) & goto toggle_loop
if /i "!CHOICE!"=="3" if !DO_DEPS! EQU 0 (set DO_DEPS=1) else (set DO_DEPS=0) & goto toggle_loop
if /i "!CHOICE!"=="4" if !DO_SCRIPT! EQU 0 (set DO_SCRIPT=1) else (set DO_SCRIPT=0) & goto toggle_loop
if /i "!CHOICE!"=="5" if !DO_GIT! EQU 0 (set DO_GIT=1) else (set DO_GIT=0) & goto toggle_loop
if /i "!CHOICE!"=="6" if !DO_SUMMARY! EQU 0 (set DO_SUMMARY=1) else (set DO_SUMMARY=0) & goto toggle_loop
if /i "!CHOICE!"=="7" if !DO_VSCODE! EQU 0 (set DO_VSCODE=1) else (set DO_VSCODE=0) & goto toggle_loop
if /i "!CHOICE!"=="8" if !DO_ACTIVATE! EQU 0 (set DO_ACTIVATE=1) else (set DO_ACTIVATE=0) & goto toggle_loop

if /i "!CHOICE!"=="R" goto run_selected
if /i "!CHOICE!"=="Q" exit /b 0

goto toggle_loop

:run_selected
if !DO_PY! EQU 1 call :handle_python_version
if !DO_VENV! EQU 1 call :handle_virtual_environment
if !DO_DEPS! EQU 1 call :handle_dependencies
if !DO_SCRIPT! EQU 1 call :handle_main_script
if !DO_GIT! EQU 1 call :handle_git_init
if !DO_SUMMARY! EQU 1 call :print_summary
if !DO_VSCODE! EQU 1 call :handle_vscode
if !DO_ACTIVATE! EQU 1 call :activate_venv
pause
goto toggle_loop


:: ==========================================
:: EXTRA FUNCTIONS
:: ==========================================
:handle_git_init
if exist .git (
    echo %GREEN%[OK]%RESET% Git repo already exists.
) else (
    where git >nul 2>&1 || (echo %YELLOW%[WARN]%RESET% Git not found & goto :eof)
    git init
    if not exist .gitignore (
        (
          echo # Virtual Environment
          echo .venv/
          echo
          echo # Config & Secrets
          echo config.json
          echo uv_project_config.json
          echo .env
          echo
          echo # Python Caches
          echo __pycache__/
          echo *.pyc
          echo
          echo # Logs
          echo *.log
          echo
          echo # IDE / Editor specific
          echo .idea/
          echo .vscode/
          echo
          echo # OS-specific
          echo .DS_Store
        ) > .gitignore
    )
    echo %GREEN%[OK]%RESET% Git initialized with .gitignore.
)
goto :eof

:print_summary
echo %BLUE%========================================%RESET%
echo SUMMARY
if defined PYVER (
    echo Python: %PYVER%
) else (
    echo Python: system default
)
if exist .venv (
    echo Venv:   .venv (active version: !VENV_PY!)
) else (
    echo Venv:   none
)
echo Script: %MAINSCRIPT%
echo %BLUE%========================================%RESET%
goto :eof

:handle_vscode
where code >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo %GREEN%[OK]%RESET% Launching VS Code...
    code .
) else (
    echo %YELLOW%[WARN]%RESET% VS Code not installed or not in PATH.
)
goto :eof

:activate_venv
if exist .venv\Scripts\activate.bat (
    echo %GREEN%[OK]%RESET% Opening new terminal with venv activated...
    start "Activated Venv" cmd /k ".venv\Scripts\activate.bat"
) else (
    echo %RED%[ERROR]%RESET% No virtual environment found to activate.
    pause
)
goto :eof
