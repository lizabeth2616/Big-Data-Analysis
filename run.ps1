# run.ps1 - ETL script (English version)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting ETL Process" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

Set-Location C:\BD_laba4

Write-Host "`n[1/4] Starting Docker containers..." -ForegroundColor Yellow
docker-compose up -d

Write-Host "`n[2/4] Waiting for containers to be ready (30 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host "`n[3/4] Running ETL transformation..." -ForegroundColor Yellow
docker exec -i trino trino --execute "$(Get-Content -Raw etl_transform.sql -ErrorAction SilentlyContinue)" 2>&1

Write-Host "`n[4/4] Creating reports..." -ForegroundColor Yellow
docker exec -i trino trino --execute "$(Get-Content -Raw create_reports.sql -ErrorAction SilentlyContinue)" 2>&1

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "DONE! All reports created!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green