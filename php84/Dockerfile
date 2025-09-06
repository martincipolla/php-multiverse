FROM php:8.4-apache

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
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mysqli pdo pdo_mysql zip intl exif opcache bcmath

RUN a2enmod rewrite
RUN echo "date.timezone=America/Argentina/Buenos_Aires" > /usr/local/etc/php/conf.d/timezone.ini

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Add Composer bin directory to PATH
ENV PATH="/root/.composer/vendor/bin:${PATH}"
