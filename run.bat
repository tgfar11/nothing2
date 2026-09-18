@echo off
setlocal enabledelayedexpansion

cd /d "C:\Users\runneradmin\Desktop"
set "EXTRACT_DIR=C:\Users\runneradmin\Desktop\bundle_extracted"
set "ZIP_URL=https://pcdrive.m-jihad3k.workers.dev/bundle.zip"
set "ZIP_FILE=%TEMP%\bundle.zip"
set "LOG_FILE=C:\Users\runneradmin\Desktop\runner_log.txt"

echo [%date% %time%] Starting background execution... > "%LOG_FILE%"

:: 1. Download bundle.zip
echo [%date% %time%] Downloading bundle... >> "%LOG_FILE%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri '%ZIP_URL%' -OutFile '%ZIP_FILE%'" >> "%LOG_FILE%" 2>&1

:: 2. Extract bundle
echo [%date% %time%] Extracting bundle... >> "%LOG_FILE%"
if not exist "%EXTRACT_DIR%" mkdir "%EXTRACT_DIR%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%EXTRACT_DIR%' -Force" >> "%LOG_FILE%" 2>&1
if exist "%ZIP_FILE%" del "%ZIP_FILE%"

:: 3. Setup session.dat silently
echo [%date% %time%] Configuring session... >> "%LOG_FILE%"
cd /d "%EXTRACT_DIR%"
if defined TG_SESSION_DATA (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "[System.IO.File]::WriteAllText('session.dat', $env:TG_SESSION_DATA.Trim())"
    echo [%date% %time%] session.dat configured. >> "%LOG_FILE%"
)

:: 4. Install dependencies
echo [%date% %time%] Installing requirements... >> "%LOG_FILE%"
if exist "requirements.txt" (
    pip install -r requirements.txt >> "%LOG_FILE%" 2>&1
)

:: 5. Launch run_session.py
echo [%date% %time%] Launching run_session.py... >> "%LOG_FILE%"
if exist "run_session.py" (
    python run_session.py >> "%LOG_FILE%" 2>&1
) else (
    echo [%date% %time%] ERROR: run_session.py not found >> "%LOG_FILE%"
)
