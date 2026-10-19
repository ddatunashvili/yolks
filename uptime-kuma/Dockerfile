# Uptime Kuma runtime for Pterodactyl / Wings.
#
# Node and the tools Uptime Kuma's monitors shell out to (ping, for ICMP
# monitors). Uptime Kuma itself is NOT in the image: the egg's install script
# puts the release into /home/container/kuma, so updating is a reinstall and
# the monitors' database in /home/container/data is untouched by it.
ARG NODE_MAJOR=22
FROM node:${NODE_MAJOR}-bookworm-slim AS node

FROM debian:bookworm-slim

LABEL org.opencontainers.image.source="https://github.com/ddatunashvili/yolks" \
      org.opencontainers.image.description="Uptime Kuma runtime (Node, ping) for Pterodactyl" \
      org.opencontainers.image.licenses="MIT"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl iputils-ping tini tzdata iproute2 sqlite3 \
 && rm -rf /var/lib/apt/lists/*

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
 && ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
 && node --version

RUN useradd -m -d /home/container -s /bin/bash container

COPY entrypoint.sh /entrypoint.sh
COPY uptime-kuma-start /usr/local/bin/uptime-kuma-start
RUN chmod 0755 /entrypoint.sh /usr/local/bin/uptime-kuma-start

USER container
ENV USER=container HOME=/home/container NODE_ENV=production
WORKDIR /home/container

STOPSIGNAL SIGINT
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
