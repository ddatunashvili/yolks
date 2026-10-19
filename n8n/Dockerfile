# n8n for Pterodactyl / Wings.
#
# n8n's npm install is close to 3 GB and takes minutes, while the official
# image carries the same release pruned to a fraction of that, so this one is
# built on the official image rather than on Debian. That image has no bash and
# no package manager, so bash is copied in from Alpine (both are musl).
#
# n8n's data (SQLite database, encryption config, binary data) lives in
# /home/container/.n8n through N8N_USER_FOLDER, so backups cover it.
ARG N8N_VERSION=2.43.7
FROM alpine:3.22 AS bash
RUN apk add --no-cache bash \
 && mkdir -p /out/lib \
 && cp /bin/bash /out/bash \
 && for lib in $(ldd /bin/bash | awk '/=>/ {print $3}'); do cp -L "$lib" /out/lib/; done

FROM n8nio/n8n:${N8N_VERSION}
ARG N8N_VERSION

LABEL org.opencontainers.image.source="https://github.com/ddatunashvili/yolks" \
      org.opencontainers.image.description="n8n ${N8N_VERSION} for Pterodactyl" \
      org.opencontainers.image.licenses="Sustainable Use License (n8n), MIT (image scripts)"

USER root
COPY --from=bash /out/bash /bin/bash
COPY --from=bash /out/lib/ /usr/lib/
RUN /bin/bash -c 'echo bash ok' \
 && adduser -D -h /home/container -s /bin/bash container 2>/dev/null \
    || (echo "container:x:1001:1001::/home/container:/bin/bash" >> /etc/passwd \
        && echo "container:x:1001:" >> /etc/group \
        && mkdir -p /home/container && chown 1001:1001 /home/container)

COPY entrypoint.sh /entrypoint.sh
COPY n8n-start /usr/local/bin/n8n-start
RUN chmod 0755 /entrypoint.sh /usr/local/bin/n8n-start

USER container
ENV USER=container HOME=/home/container \
    N8N_USER_FOLDER=/home/container \
    N8N_RELEASE_TYPE=stable
WORKDIR /home/container

STOPSIGNAL SIGINT
ENTRYPOINT ["/sbin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
