@echo off
REM Highlands Coffee Backend Starter (Windows Batch)

echo ========================================
echo  Highlands Coffee - Backend Starter
echo ========================================

REM Navigate to backend directory
cd /d "%~dp0backend"

REM Check if .env exists, create from env.example if not
if not exist ".env" (
    if exist "env.example" (
        echo Creating .env from env.example...
        copy "env.example" ".env" >nul
    )
)

REM Check Node.js installation
node -v >nul 2>&1
if errorlevel 1 (
    echo ERROR: Node.js is not installed or not found in PATH.
    echo Please install Node.js 18+ from https://nodejs.org/
    pause
    exit /b 1
)

REM Check Node.js version (basic check for v18+)
for /f "tokens=1 delims=v" %%i in ('node -v') do set NODE_VERSION=%%i
for /f "tokens=1 delims=." %%i in ("%NODE_VERSION%") do set NODE_MAJOR=%%i

if %NODE_MAJOR% LSS 18 (
    echo ERROR: Node.js version 18+ is required. Found version %NODE_VERSION%
    pause
    exit /b 1
)

REM Install dependencies
if exist "package-lock.json" (
    echo Installing dependencies with npm ci...
    npm ci --no-fund --no-audit
) else (
    echo Installing dependencies with npm install...
    npm install --no-fund --no-audit
)

if errorlevel 1 (
    echo ERROR: Dependency installation failed.
    pause
    exit /b 1
)

REM Check for dev mode parameter
if "%1"=="dev" (
    echo Starting backend in DEV mode (nodemon)...
    npm run dev
) else (
    echo Starting backend...
    npm start
)

if errorlevel 1 (
    echo ERROR: Backend failed to start.
    pause
    exit /b 1
)

pause



