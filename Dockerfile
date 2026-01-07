FROM php:8.2-cli-alpine

# Dépendances système
RUN apk add --no-cache \
    bash \
    git \
    unzip \
    icu-dev \
    libzip-dev \
    oniguruma-dev \
    curl \
    && docker-php-ext-install intl zip opcache

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

# Copier le projet
COPY . .

# Installer les dépendances PHP (sans dev)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Préparer Symfony en prod
ENV APP_ENV=prod
ENV APP_DEBUG=0

RUN php bin/console cache:clear --env=prod
RUN php bin/console cache:warmup --env=prod

EXPOSE 8000

CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
