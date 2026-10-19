# Directus for Pterodactyl / Wings.
#
# The official image (the npm package needs a native build of sharp and
# sqlite3 per platform, which the image already carries), re-based for a
# panel: tini, the unprivileged `container` user, and the SQLite database,
# uploads and extensions under /home/container.
ARG DIRECTUS_VERSION=12.5.0
FROM directus/directus:${DIRECTUS_VERSION}

ARG DIRECTUS_VERSION
LABEL org.opencontainers.image.source="https://github.com/ddatunashvili/yolks" \
      org.opencontainers.image.description="Directus ${DIRECTUS_VERSION} for Pterodactyl" \
      org.opencontainers.image.licenses="MIT"

USER root
# The node base image owns uid 1000 as `node`; hand it to `container`.
RUN apk add --no-cache bash tini iproute2 ca-certificates curl tzdata \
 && (deluser --remove-home node 2>/dev/null || true) \
 && adduser -D -u 1000 -h /home/container -s /bin/bash container \
 && echo "${DIRECTUS_VERSION}" > /directus/.renode-version

COPY entrypoint.sh /entrypoint.sh
COPY directus-start /usr/local/bin/directus-start
RUN chmod 0755 /entrypoint.sh /usr/local/bin/directus-start

USER container
ENV USER=container HOME=/home/container \
    DB_CLIENT=sqlite3 \
    DB_FILENAME=/home/container/database/data.db \
    STORAGE_LOCATIONS=local \
    STORAGE_LOCAL_ROOT=/home/container/uploads \
    EXTENSIONS_PATH=/home/container/extensions \
    TELEMETRY=false
WORKDIR /home/container

STOPSIGNAL SIGINT
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
