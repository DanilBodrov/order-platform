$ErrorActionPreference = "Stop"

Write-Host "Starting order-platform local infrastructure..." -ForegroundColor Cyan

if (-not (Test-Path ".env")) {
    Write-Host ".env not found. Copying from .env.example..." -ForegroundColor Yellow
    Copy-Item ".env.example" ".env"
}

docker compose up -d

Write-Host ""
Write-Host "Infrastructure is starting." -ForegroundColor Green
docker compose ps

Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Cyan
Write-Host "  docker compose logs -f       # follow logs"
Write-Host "  docker compose ps            # status"
Write-Host "  .\scripts\dev-down.ps1       # stop"
