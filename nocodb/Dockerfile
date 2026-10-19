# NocoDB for Pterodactyl / Wings.
#
# The official image (NocoDB ships its server only as a built image), re-based
# for a panel: tini, the unprivileged `container` user, and every byte of
# state — the SQLite metadata database and uploads — under /home/container.
ARG NOCODB_VERSION=2026.09.1
FROM nocodb/nocodb:${NOCODB_VERSION}

ARG NOCODB_VERSION
LABEL org.opencontainers.image.source="https://github.com/ddatunashvili/yolks" \
      org.opencontainers.image.description="NocoDB ${NOCODB_VERSION} for Pterodactyl" \
      org.opencontainers.image.licenses="MIT"

USER root
# The node base image owns uid 1000 as `node`; hand it to `container`.
RUN apk add --no-cache bash tini iproute2 ca-certificates curl tzdata \
 && (deluser --remove-home node 2>/dev/null || true) \
 && adduser -D -u 1000 -h /home/container -s /bin/bash container \
 && echo "${NOCODB_VERSION}" > /usr/src/app/.renode-version

COPY entrypoint.sh /entrypoint.sh
COPY nocodb-start /usr/local/bin/nocodb-start
RUN chmod 0755 /entrypoint.sh /usr/local/bin/nocodb-start

USER container
ENV USER=container HOME=/home/container \
    NC_TOOL_DIR=/home/container/nocodb/ \
    NC_DISABLE_TELE=true
WORKDIR /home/container

STOPSIGNAL SIGINT
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
