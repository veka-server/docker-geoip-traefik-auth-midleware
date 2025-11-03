FROM alpine:latest

# Installer PHP, FPM, Composer et utilitaires
RUN apk add --no-cache php83 curl gzip unzip composer

# Copier l'application
COPY ./src /app

# Copier la Database depuis custom_data recup dans le github action
COPY ./custom_data/location.mmdb /app/location.mmdb

# Permissions (optionnel selon l'utilisateur du conteneur)
RUN chmod 644 /app/location.mmdb

WORKDIR /app

# Installer les dépendances PHP
RUN composer install --no-dev --optimize-autoloader

EXPOSE 8080

# Lancer le serveur PHP intégré au runtime
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/app", "-r", "index.php"]
