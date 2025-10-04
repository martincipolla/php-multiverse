#!/bin/bash
# Script to optimize Laravel projects in PHP containers
# Usage: ./optimize-laravel.sh <php_version> <project_name>
# Example: ./optimize-laravel.sh php84 boilerplate

set -e

if [ $# -lt 2 ]; then
    echo "❌ Error: Missing arguments"
    echo ""
    echo "Usage: $0 <php_version> <project_name>"
    echo ""
    echo "Examples:"
    echo "  $0 php84 boilerplate"
    echo "  $0 php74 my-project"
    echo "  $0 php56 legacy-app"
    echo ""
    echo "Available PHP versions: php56, php74, php84"
    exit 1
fi

PHP_VERSION=$1
PROJECT_NAME=$2
CONTAINER_NAME="${PHP_VERSION}_apache"

echo "🚀 Optimizing Laravel project: $PROJECT_NAME in $PHP_VERSION"
echo ""

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "❌ Error: Container $CONTAINER_NAME is not running"
    echo "Run: docker-compose up -d"
    exit 1
fi

# Check if project directory exists
if ! docker exec $CONTAINER_NAME test -d "/var/www/html/${PROJECT_NAME}"; then
    echo "❌ Error: Project directory /var/www/html/${PROJECT_NAME} does not exist"
    exit 1
fi

echo "📦 Optimizing Composer autoloader..."
docker exec $CONTAINER_NAME bash -c "cd /var/www/html/${PROJECT_NAME} && composer dump-autoload -o"

echo "⚙️  Caching Laravel configuration..."
docker exec $CONTAINER_NAME bash -c "cd /var/www/html/${PROJECT_NAME} && php artisan config:cache"

echo "🛣️  Caching Laravel routes..."
docker exec $CONTAINER_NAME bash -c "cd /var/www/html/${PROJECT_NAME} && php artisan route:cache"

echo "👁️  Caching Laravel views..."
docker exec $CONTAINER_NAME bash -c "cd /var/www/html/${PROJECT_NAME} && php artisan view:cache"

echo ""
echo "✅ Project $PROJECT_NAME optimized successfully!"
echo ""
echo "💡 Tips:"
echo "  - If you make config/route changes, run: php artisan optimize:clear"
echo "  - To clear all caches: docker exec -it $CONTAINER_NAME php artisan optimize:clear"
echo "  - Monitor performance with: docker stats $CONTAINER_NAME"
