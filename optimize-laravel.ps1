# Script to optimize Laravel projects in PHP containers (PowerShell version)
# Usage: .\optimize-laravel.ps1 <php_version> <project_name>
# Example: .\optimize-laravel.ps1 php84 boilerplate

param(
    [Parameter(Mandatory=$true)]
    [string]$PhpVersion,
    
    [Parameter(Mandatory=$true)]
    [string]$ProjectName
)

$ErrorActionPreference = "Stop"

$ContainerName = "${PhpVersion}_apache"

Write-Host "🚀 Optimizing Laravel project: $ProjectName in $PhpVersion" -ForegroundColor Cyan
Write-Host ""

# Check if container is running
$runningContainers = docker ps --format "{{.Names}}"
if ($runningContainers -notcontains $ContainerName) {
    Write-Host "❌ Error: Container $ContainerName is not running" -ForegroundColor Red
    Write-Host "Run: docker-compose up -d" -ForegroundColor Yellow
    exit 1
}

# Check if project directory exists
$checkDir = docker exec $ContainerName test -d "/var/www/html/$ProjectName"
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error: Project directory /var/www/html/$ProjectName does not exist" -ForegroundColor Red
    exit 1
}

Write-Host "📦 Optimizing Composer autoloader..." -ForegroundColor Yellow
docker exec $ContainerName bash -c "cd /var/www/html/$ProjectName && composer dump-autoload -o"

Write-Host "⚙️  Caching Laravel configuration..." -ForegroundColor Yellow
docker exec $ContainerName bash -c "cd /var/www/html/$ProjectName && php artisan config:cache"

Write-Host "🛣️  Caching Laravel routes..." -ForegroundColor Yellow
docker exec $ContainerName bash -c "cd /var/www/html/$ProjectName && php artisan route:cache"

Write-Host "👁️  Caching Laravel views..." -ForegroundColor Yellow
docker exec $ContainerName bash -c "cd /var/www/html/$ProjectName && php artisan view:cache"

Write-Host ""
Write-Host "✅ Project $ProjectName optimized successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Tips:" -ForegroundColor Cyan
Write-Host "  - If you make config/route changes, run: php artisan optimize:clear"
Write-Host "  - To clear all caches: docker exec -it $ContainerName php artisan optimize:clear"
Write-Host "  - Monitor performance with: docker stats $ContainerName"
