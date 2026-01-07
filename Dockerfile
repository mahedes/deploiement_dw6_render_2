# ---------- Étape 1 : Base PHP ----------
FROM php:8.2-fpm-alpine

# Installer dépendances système et extensions PHP nécessaires
RUN apk add --no-cache \
    bash \
    git \
    unzip \
    libzip-dev \
    oniguruma-dev \
    icu-dev \
    mariadb-client \
    nodejs \
    npm \
    curl \
    shadow \
    && docker-php-ext-install pdo pdo_mysql intl opcache zip bcmath \
    && docker-php-ext-enable opcache

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# ---------- Étape 2 : Préparer le projet ----------
WORKDIR /var/www/html

# Copier les fichiers du projet
COPY . .

# Installer dépendances PHP
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

# Installer les dépendances front et builder assets
RUN npm install && npm run build

# ---------- Étape 3 : Préparer Symfony prod ----------
# Nettoyer et chauffer le cache pour la production
RUN php bin/console cache:clear --env=prod --no-debug
RUN php bin/console cache:warmup --env=prod

# Définir variables d'environnement par défaut (modifiable sur Render)
ENV APP_ENV=prod
ENV APP_DEBUG=0

# Exposer le port pour Render
EXPOSE 8000

# ---------- Étape 4 : Commande de lancement ----------
# On utilise le serveur PHP interne de Symfony
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public"]
