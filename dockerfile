FROM alpine:latest

# Token IPinfo à passer via build-arg ou variable d'environnement au runtime
ARG TOKEN_IPINFO
ENV TOKEN_IPINFO=${TOKEN_IPINFO}

# Installer PHP, FPM, Composer et utilitaires
RUN apk add --no-cache php83 curl gzip unzip composer

# Copier l'application
COPY ./src /app
WORKDIR /app

# Installer les dépendances PHP
RUN composer install --no-dev --optimize-autoloader

# Charger les secrets de build (ex: TOKEN_IPINFO, APP_ENV, etc.)
# Ce bloc lit le contenu du secret nommé "build_args"
RUN --mount=type=secret,id=build_args \
    if [ -f /run/secrets/build_args ]; then \
      echo "📥 Chargement du secret build_args..."; \
      while IFS='=' read -r key value; do \
        if [ -n "$key" ]; then \
          echo "→ Export $key"; \
          export "$key"="$value"; \
        fi; \
      done < /run/secrets/build_args; \
    else \
      echo "⚠️ Aucun secret build_args trouvé."; \
    fi && \
    # Si TOKEN_IPINFO est présent, télécharger la base IPinfo Lite
    if [ -n "$TOKEN_IPINFO" ]; then \
      echo "🔑 Téléchargement de la base IPinfo Lite..."; \
      curl -fsSL "https://ipinfo.io/data/location.mmdb.gz?token=${TOKEN_IPINFO}" -o location.mmdb.gz && \
      gunzip -f location.mmdb.gz && \
      echo "✅ Base IPinfo Lite téléchargée avec succès."; \
    else \
      echo "⚠️ Aucun TOKEN_IPINFO trouvé, téléchargement ignoré."; \
    fi

# Récupérer la base IPinfo Lite (GeoIP)
RUN curl -L "https://ipinfo.io/data/location.mmdb.gz?token=${TOKEN_IPINFO}" -o /tmp/location.mmdb.gz \
    && gzip -d /tmp/location.mmdb.gz \
    && mv /tmp/location.mmdb /app/location.mmdb \
    && rm -f /tmp/location.mmdb.gz

# Permissions (optionnel selon l'utilisateur du conteneur)
RUN chmod 644 /app/location.mmdb

EXPOSE 8080

# Lancer le serveur PHP intégré au runtime
CMD ["php", "-S", "0.0.0.0:8080", "-t", "/app", "index.php"]
