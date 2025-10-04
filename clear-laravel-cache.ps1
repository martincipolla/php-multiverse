# Script to clear Laravel caches (PowerShell version)
# Usage: .\clear-laravel-cache.ps1 <php_version> <project_name>
# Example: .\clear-laravel-cache.ps1 php84 boilerplate

param(
    [Parameter(Mandatory=$true)]
    [string]$PhpVersion,
    
    [Parameter(Mandatory=$true)]
    [string]$ProjectName
)

$ErrorActionPreference = "Stop"

$ContainerName = "${PhpVersion}_apache"

Write-Host "🧹 Clearing Laravel caches for: $ProjectName in $PhpVersion" -ForegroundColor Cyan
Write-Host ""

# Check if container is running
$runningContainers = docker ps --format "{{.Names}}"
if ($runningContainers -notcontains $ContainerName) {
    Write-Host "❌ Error: Container $ContainerName is not running" -ForegroundColor Red
    Write-Host "Run: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

Write-Host "🗑️  Clearing all Laravel caches..." -ForegroundColor Yellow
docker exec $ContainerName bash -c "cd /var/www/html/$ProjectName && php artisan optimize:clear"

Write-Host ""
Write-Host "✅ Caches cleared successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Now you can run: .\optimize-laravel.ps1 $PhpVersion $ProjectName" -ForegroundColor Cyan
