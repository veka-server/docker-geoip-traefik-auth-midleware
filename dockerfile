FROM alpine:latest

# Installer PHP, FPM, Composer et utilitaires
RUN apk add --no-cache php83 composer

# Copier l'application
COPY ./src /app

# Copier la Database depuis custom_data recup dans le github action
COPY ./custom_data/location.mmdb /app/location.mmdb

# Copier conditionnellement la base s’il existe
RUN if [ -f ./custom_data/location.mmdb ]; then \
      echo "Copie du fichier location.mmdb détecté"; \
      mkdir -p /app && cp ./custom_data/location.mmdb /app/location.mmdb; \
      chmod 644 /app/location.mmdb \
    else \
      echo "Aucun fichier location.mmdb trouvé, passage"; \
    fi

WORKDIR /app

# Installer les dépendances PHP
RUN composer install --no-dev --optimize-autoloader

EXPOSE 8080

# Lancer le serveur PHP intégré au runtime
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/app", "-r", "index.php"]
