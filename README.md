# PHP Multiverse

![PHP Versions](https://img.shields.io/badge/PHP-5.6%20|%207.4%20|%208.4-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Docker](https://img.shields.io/badge/Docker-Ready-blue)

📈 **TL;DR**: Entorno Docker con PHP 5.6, 7.4 y 8.4 + MySQL + MongoDB, todo listo para usar.

## ¿Por qué creé esto?

Como desarrollador, me encontré con el desafío de mantener varios proyectos PHP simultáneamente, cada uno con diferentes requisitos de versión. Algunos proyectos legacy en PHP 5.6, otros más recientes en 7.4, y nuevos desarrollos en PHP 8.x.

Cambiar constantemente entre versiones de PHP en mi máquina local era un dolor de cabeza, así que decidí crear este entorno Docker que me permite trabajar con todas las versiones simultáneamente, sin conflictos y de manera aislada.

Comparto esta solución esperando que pueda ayudar a otros desarrolladores que se encuentren en una situación similar. 😎

## Características Principales

- **Múltiples Versiones de PHP**: Incluye PHP 5.6, 7.4 y 8.4, cada una en su propio contenedor
- **Servidor Web Apache**: Cada versión de PHP viene con Apache configurado
- **Composer Preinstalado**: Versiones específicas de Composer para cada versión de PHP
- **Bases de Datos**:
  - MySQL 5.7 para proyectos que requieren compatibilidad con versiones anteriores
  - MongoDB 6 para aplicaciones modernas que necesitan una base de datos NoSQL
- **Extensiones PHP**: Incluye las extensiones más comunes (GD, MySQLi, PDO, ZIP)
- **Puertos Alternativos**: Configurado para evitar conflictos con servicios locales existentes

## Casos de Uso

- Desarrollo de aplicaciones PHP modernas
- Mantenimiento de aplicaciones legacy
- Pruebas de compatibilidad entre versiones
- Migraciones de aplicaciones entre diferentes versiones de PHP

## Requisitos

- Docker
- Docker Compose

## Estructura del Proyecto

```
.
├── php56/
│   ├── src/           # Archivos PHP 5.6
│   └── Dockerfile
├── php74/
│   ├── src/           # Archivos PHP 7.4
│   └── Dockerfile
├── php84/
│   ├── src/           # Archivos PHP 8.4
│   └── Dockerfile
└── docker-compose.yml
```

## Instalación y Ejecución

1. Clonar el repositorio
2. Construir las imágenes:
   ```bash
   docker-compose build
   ```
3. Ejecutar los contenedores:
   ```bash
   docker-compose up -d
   ```

## Acceso a los Servicios

- PHP 5.6: http://localhost:8056
- PHP 7.4: http://localhost:8074
- PHP 8.4: http://localhost:8084
- MySQL: localhost:3307 (puerto alternativo para evitar conflictos)
- MongoDB: localhost:27018 (puerto alternativo para evitar conflictos)

## Configuración

### Credenciales por Defecto

**MySQL:**

- Host: localhost:3307
- Usuario: root
- Contraseña: root

**MongoDB:**

- Host: localhost:27018
- Sin autenticación por defecto

### Ejemplos de Conexión

**MySQL desde PHP:**

```php
$mysqli = new mysqli('mysql', 'root', 'root', 'database');
// O usando PDO
$pdo = new PDO('mysql:host=mysql;dbname=database', 'root', 'root');
```

**MongoDB desde PHP:**

```php
$mongo = new MongoDB\Client('mongodb://mongo:27017');
```

## Personalización

### Agregar Extensiones PHP

Modifica el Dockerfile correspondiente agregando la extensión deseada:

```dockerfile
RUN docker-php-ext-install nombre_extension
```

### Modificar Configuración PHP

Agrega archivos .ini en la carpeta conf.d:

```dockerfile
COPY mi-config.ini /usr/local/etc/php/conf.d/
```

## Solución de Problemas

### Puertos en Uso

Si encuentras errores de puertos en uso, puedes modificar los puertos en `docker-compose.yml`:

```yaml
ports:
  - "nuevo_puerto:puerto_contenedor"
```

### Permisos de Archivos

Si encuentras problemas de permisos:

```bash
# En el host
chmod -R 777 ./php*/src
```

### Logs de Contenedores

Para ver logs en tiempo real:

```bash
docker-compose logs -f [servicio]
```

## Detener el Entorno

Para detener todos los contenedores:

```bash
docker-compose down
```

Para detener y eliminar volúmenes:

```bash
docker-compose down -v
```

## Agregar Nuevas Versiones de PHP

Puedes agregar fácilmente soporte para otras versiones de PHP siguiendo estos pasos:

1. Crea una nueva carpeta para tu versión:

```bash
mkdir php73
mkdir php73/src
```

2. Crea un nuevo Dockerfile (ejemplo para PHP 7.3):

```dockerfile
FROM php:7.3-apache

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd mysqli pdo pdo_mysql zip

RUN a2enmod rewrite
RUN echo "date.timezone=America/Argentina/Buenos_Aires" > /usr/local/etc/php/conf.d/timezone.ini

# Install Composer (ajusta la versión según compatibilidad)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
```

3. Agrega el servicio en docker-compose.yml:

```yaml
php73:
  build: ./php73
  container_name: php73_apache
  volumes:
    - ./php73/src:/var/www/html
  ports:
    - "8073:80"
  networks:
    - devnet
```

4. Reconstruye los contenedores:

```bash
docker-compose build php73
docker-compose up -d
```

Puedes seguir este mismo patrón para cualquier versión de PHP soportada por la [imagen oficial de PHP en Docker Hub](https://hub.docker.com/_/php).

## Desarrollo con Vite

Los contenedores incluyen soporte para desarrollo con Vite (Node.js y npm). Los puertos están configurados de la siguiente manera:

- PHP 8.4: puerto 5173 (estándar de Vite)
- PHP 7.4: puerto 5174
- PHP 5.6: puerto 5156

```bash
docker exec -it php84_apache bash  # o php74_apache/php56_apache
cd /var/www/html/[proyecto]
npm install
npm run dev
```

## Optimización de Performance

### Problema en Windows

En Windows, los bind mounts desde `C:\...` hacia contenedores Docker tienen un overhead significativo de I/O. Laravel toca cientos de archivos en cada request (autoloader, views, cache), lo que puede causar tiempos de carga de varios segundos.

### Optimizaciones Implementadas

Este proyecto incluye varias optimizaciones para mejorar la performance en desarrollo:

#### 1. OPcache Configurado

Cada versión de PHP tiene OPcache habilitado con configuración optimizada para desarrollo:

- **Cachea bytecode PHP** compilado (reduce parsing)
- **Revalidación instantánea** (`revalidate_freq=0`) - detecta cambios al instante
- **JIT habilitado en PHP 8.4** para máxima performance

#### 2. Realpath Cache

Configuración de `realpath_cache` para reducir llamadas al filesystem:

```ini
realpath_cache_size=4096K
realpath_cache_ttl=600
```

#### 3. Volúmenes con Flag `cached`

Los volúmenes en `docker-compose.yml` usan el flag `:cached` para mejorar I/O en Windows:

```yaml
volumes:
  - ./php84/src:/var/www/html:cached
```

### Scripts de Optimización para Laravel

#### Optimizar un Proyecto

Para proyectos Laravel, usa el script de optimización que cachea autoloader, config, routes y views:

**PowerShell (Windows):**

```powershell
.\optimize-laravel.ps1 php84 nombre-proyecto
```

**Bash (Git Bash/WSL):**

```bash
./optimize-laravel.sh php84 nombre-proyecto
```

**Ejemplo:**

```powershell
.\optimize-laravel.ps1 php84 boilerplate
```

Esto ejecuta:

- `composer dump-autoload -o` - Optimiza autoloader
- `php artisan config:cache` - Cachea configuración
- `php artisan route:cache` - Cachea rutas
- `php artisan view:cache` - Cachea vistas Blade

#### Limpiar Caches

Si haces cambios en config, rutas o necesitas limpiar caches:

**PowerShell:**

```powershell
.\clear-laravel-cache.ps1 php84 nombre-proyecto
```

**Manualmente:**

```bash
docker exec -it php84_apache bash
cd /var/www/html/nombre-proyecto
php artisan optimize:clear
```

### Comandos Útiles de Performance

#### Ver uso de recursos del contenedor

```bash
docker stats php84_apache
```

#### Verificar configuración de OPcache

```bash
docker exec -it php84_apache php -i | grep opcache
```

#### Verificar realpath cache

```bash
docker exec -it php84_apache php -i | grep realpath
```

### Mejora Esperada

Con las optimizaciones implementadas:

- **OPcache + realpath_cache:** 30-50% más rápido
- **Volúmenes cached:** 10-20% adicional
- **Optimizaciones Laravel:** 20-40% adicional (primera carga)

**Total estimado:** 2-3x más rápido en recargas de página

### Máxima Performance (Recomendado)

Para obtener la mejor performance posible en Windows:

#### Opción A: Mover proyecto a WSL2

1. Instala WSL2 (Ubuntu recomendado)
2. Mueve el proyecto a: `\\wsl$\Ubuntu\home\<usuario>\dev\php-multiverse`
3. Ejecuta `docker-compose` desde WSL

Beneficio: **5-10x más rápido** que bind mounts desde `C:\`

#### Opción B: Activar VirtioFS en Docker Desktop

1. Docker Desktop → Settings → General
2. Activa "Use the new Virtualization framework"
3. Reinicia Docker Desktop

Beneficio: **2-4x más rápido** que bind mounts tradicionales

### Troubleshooting

#### Los cambios no se reflejan

Si los cambios en código no se reflejan:

```bash
# Limpiar caches de Laravel
docker exec -it php84_apache php artisan optimize:clear

# Verificar que OPcache revalida archivos
docker exec -it php84_apache php -r "echo opcache_get_status()['opcache_statistics']['num_cached_scripts'];"
```

## Contribuir

Las contribuciones son bienvenidas. Por favor, siéntete libre de:

1. Hacer fork del proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit de tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request
