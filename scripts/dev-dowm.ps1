$ErrorActionPreference = "Stop"

Write-Host "Stopping order-platform local infrastructure..." -ForegroundColor Cyan
docker compose down
Write-Host "Stopped." -ForegroundColor Green
