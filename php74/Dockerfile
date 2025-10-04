FROM php:7.4-apache

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    git \
    nano \
    libicu-dev \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mysqli pdo pdo_mysql zip intl exif opcache bcmath

# Install Node.js and npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --allow-unauthenticated nodejs

RUN a2enmod rewrite
RUN echo "date.timezone=America/Argentina/Buenos_Aires" > /usr/local/etc/php/conf.d/timezone.ini

# Copy performance configuration files
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY php-performance.ini /usr/local/etc/php/conf.d/php-performance.ini

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Add Composer bin directory to PATH
ENV PATH="/root/.composer/vendor/bin:${PATH}"
