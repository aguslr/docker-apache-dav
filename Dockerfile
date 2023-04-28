ARG BASE_IMAGE=library/debian:bullseye-slim

FROM docker.io/${BASE_IMAGE}

RUN \
  apt-get update && \
  env DEBIAN_FRONTEND=noninteractive \
  apt-get install -y --no-install-recommends apache2 apache2-utils curl \
  -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /var/lib/apt/lists/*

RUN \
  mkdir -p /etc/apache2/dav.d && \
  mkdir -p /var/lib/dav/lockdb && \
  chown www-data:www-data /var/lib/dav/lockdb && \
  sed -i \
  '/^LogFormat/s/ "%h %l/ "%{X-Forwarded-For}i %l/' \
  /etc/apache2/apache2.conf && \
  sed -i \
  -e '/^ServerTokens/s/ .*$/ Prod/' \
  -e '/^ServerSignature/s/ .*$/ Off/' \
  /etc/apache2/conf-enabled/security.conf

COPY entrypoint.sh /entrypoint.sh
COPY dav.conf /etc/apache2/sites-enabled/000-default.conf

EXPOSE 80/tcp

VOLUME /data /etc/apache2/dav.d

HEALTHCHECK --interval=1m --timeout=3s \
  CMD curl -sfo /dev/null -u 'guest:' 'http://127.0.0.1:80'

ENTRYPOINT ["/entrypoint.sh"]
CMD ["-D", "FOREGROUND"]
