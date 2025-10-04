FROM php:5.6-apache

# Configure apt to use archive.debian.org for Debian Stretch
RUN echo 'deb http://archive.debian.org/debian/ stretch main' > /etc/apt/sources.list && \
    echo 'deb http://archive.debian.org/debian-security stretch/updates main' >> /etc/apt/sources.list && \
    apt-get update && apt-get install -y --allow-unauthenticated \
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
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install gd mysqli pdo pdo_mysql zip intl exif opcache bcmath

# Install Node.js and npm using direct package
RUN curl -fsSL https://nodejs.org/dist/v14.21.3/node-v14.21.3-linux-x64.tar.gz | tar -xz -C /usr/local --strip-components=1 \
    && ln -s /usr/local/bin/node /usr/bin/node \
    && ln -s /usr/local/bin/npm /usr/bin/npm

RUN a2enmod rewrite
RUN echo "date.timezone=America/Argentina/Buenos_Aires" > /usr/local/etc/php/conf.d/timezone.ini

# Copy performance configuration files
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini
COPY php-performance.ini /usr/local/etc/php/conf.d/php-performance.ini

# Install Composer 1.x (last version supporting PHP 5.6)
COPY --from=composer:1 /usr/bin/composer /usr/bin/composer

# Add Composer bin directory to PATH
ENV PATH="/root/.composer/vendor/bin:${PATH}"
