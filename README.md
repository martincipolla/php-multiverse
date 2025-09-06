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

## Contribuir

Las contribuciones son bienvenidas. Por favor, siéntete libre de:

1. Hacer fork del proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit de tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request
