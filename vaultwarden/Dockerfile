# Vaultwarden for Pterodactyl / Wings.
#
# The official image re-based for a panel: runs as the unprivileged
# `container` user, keeps every byte of state in /home/container/data, and
# binds the allocation Wings hands it. The web vault ships inside the
# upstream image at /web-vault and is served from there.
ARG VAULTWARDEN_VERSION=1.37.4
FROM vaultwarden/server:${VAULTWARDEN_VERSION}

ARG VAULTWARDEN_VERSION
LABEL org.opencontainers.image.source="https://github.com/ddatunashvili/yolks" \
      org.opencontainers.image.description="Vaultwarden ${VAULTWARDEN_VERSION} for Pterodactyl" \
      org.opencontainers.image.licenses="MIT"

USER root
# argon2 hashes the admin password on every start, so the plain value never
# reaches Vaultwarden's own config and the admin page stops warning about it.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl tini iproute2 argon2 \
 && rm -rf /var/lib/apt/lists/*

RUN useradd -m -d /home/container -s /bin/bash container

COPY entrypoint.sh /entrypoint.sh
COPY vaultwarden-start /usr/local/bin/vaultwarden-start
RUN chmod 0755 /entrypoint.sh /usr/local/bin/vaultwarden-start

USER container
ENV USER=container HOME=/home/container \
    DATA_FOLDER=/home/container/data \
    WEB_VAULT_FOLDER=/web-vault \
    ROCKET_ADDRESS=0.0.0.0
WORKDIR /home/container

# Upstream's check probes port 80 through /healthcheck.sh; nothing listens
# there once the port follows the allocation.
HEALTHCHECK NONE
STOPSIGNAL SIGINT
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
