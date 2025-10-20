# Starts the Highlands Coffee backend service on Windows (PowerShell)

param(
    [switch]$Dev
)

Write-Host "========================================" -ForegroundColor Green
Write-Host " HighLands Coffee - Backend Starter" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

# Navigate to backend directory
Set-Location -Path "$PSScriptRoot\backend"

# Ensure env file exists
if (-not (Test-Path ".env") -and (Test-Path "env.example")) {
    Write-Host "Creating .env from env.example..." -ForegroundColor Yellow
    Copy-Item "env.example" ".env"
}

# Node version check (>= 18)
try {
    $nodeVersion = (& node -v) -replace "^v", ""
} catch {
    Write-Error "Node.js is not installed or not found in PATH. Please install Node 18+."
    exit 1
}

function Compare-SemVer($a, $b) {
    $pa = $a.Split('.') | ForEach-Object { [int]$_ }
    $pb = $b.Split('.') | ForEach-Object { [int]$_ }
    for ($i = 0; $i -lt [Math]::Max($pa.Count, $pb.Count); $i++) {
        $va = $(if ($i -lt $pa.Count) { $pa[$i] } else { 0 })
        $vb = $(if ($i -lt $pb.Count) { $pb[$i] } else { 0 })
        if ($va -gt $vb) { return 1 }
        if ($va -lt $vb) { return -1 }
    }
    return 0
}

if ((Compare-SemVer $nodeVersion "18.0.0") -lt 0) {
    Write-Error "Node.js >= 18.0.0 is required. Found $nodeVersion"
    exit 1
}

# Install dependencies (prefer npm ci if lockfile exists)
if (Test-Path "package-lock.json") {
    Write-Host "Installing dependencies with npm ci..." -ForegroundColor Yellow
    npm ci --no-fund --no-audit
} else {
    Write-Host "Installing dependencies with npm install..." -ForegroundColor Yellow
    npm install --no-fund --no-audit
}
if ($LASTEXITCODE -ne 0) {
    Write-Error "Dependency installation failed."
    exit $LASTEXITCODE
}

# Start server
if ($Dev) {
    Write-Host "Starting backend in DEV mode (nodemon)..." -ForegroundColor Green
    npm run dev
} else {
    Write-Host "Starting backend..." -ForegroundColor Green
    npm start
}

exit $LASTEXITCODE



