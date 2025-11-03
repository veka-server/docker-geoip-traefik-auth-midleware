# docker-geoip-traefik-auth-midleware
Un conteneur Docker fournissant un service d’authentification forwardAuth pour Traefik, qui block les visiteur hors d'un pays avec les données GeoIP locales à partir d’une base MaxMind ou IPinfo au format .mmdb.

# Fonctionnalités

- Fournit une API HTTP simple compatible avec le middleware natif forwardAuth de Traefik.

- Block automatiquement (403) le visiteur hors de mon pays.

- Permet d’utiliser votre propre base .mmdb locale (MaxMind ou IPinfo).

- Utilisation 100% hors ligne.

# ou trouver la BDD
https://ipinfo.io/lite


# build :
```bash
# Cloner le dépôt
git clone https://github.com/veka-server/docker-geoip-traefik-auth-midleware.git
cd docker-geoip-traefik-auth-midleware

# (Optionnel) placer ta base GeoIP dans le dossier custom_data/
mkdir -p custom_data
cp /chemin/vers/ta/location.mmdb custom_data/location.mmdb

# Construire l’image
docker build -t geoip-auth:latest .
```

# utilisation :
```bash
docker run -d \
  --name geoip-auth \
  -p 8080:8080 \
  -v $(pwd)/custom_data/location.mmdb:/app/location.mmdb:ro \
  geoip-auth:latest
```


# utilisation dans traefik :
remplace <MY_SERVICE> par ton service, ainsi que l'url de ton service
```bash
    labels:
      # Middleware qui délègue à ton service GeoIP : Only FR
      - "traefik.http.middlewares.<MY_SERVICE>-geoip-auth.forwardAuth.address=http://geoip-auth:8080?pays=FR"
      - "traefik.http.middlewares.<MY_SERVICE>-geoip-auth.forwardAuth.trustForwardHeader=true"
      - "traefik.http.routers.<MY_SERVICE>.middlewares=<MY_SERVICE>-geoip-auth"
```


# Image private :

![Docker Pulls](https://img.shields.io/github/v/release/veka-server/docker-geoip-traefik-auth-midleware?label=GHCR)

![Build Docker](https://github.com/veka-server/docker-geoip-traefik-auth-midleware/actions/workflows/build-central.yml/badge.svg)

```bash
$ docker pull ghcr.io/veka-server/docker-geoip-traefik-auth-midleware:main
```

# Licence
Projet open-source distribué sous licence MIT.
Nécessite que vous respectiez les conditions d’utilisation de la base GeoIP utilisée (par ex. IPinfo Terms of Service).