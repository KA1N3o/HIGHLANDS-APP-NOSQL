# Monitor backend logs in real-time
Write-Host "🔍 Monitoring backend logs... (Press Ctrl+C to stop)" -ForegroundColor Cyan
Write-Host ""

$lastLineCount = 0
while ($true) {
    $job = Get-Job -Name "backend" -ErrorAction SilentlyContinue
    if (!$job) {
        Write-Host "❌ Backend job stopped!" -ForegroundColor Red
        break
    }
    
    $output = Receive-Job -Name "backend" -Keep
    if ($output) {
        $lines = $output -split "`n"
        if ($lines.Count -gt $lastLineCount) {
            $newLines = $lines[$lastLineCount..($lines.Count - 1)]
            foreach ($line in $newLines) {
                if ($line) {
                    Write-Host $line
                }
            }
            $lastLineCount = $lines.Count
        }
    }
    
    Start-Sleep -Milliseconds 500
}



