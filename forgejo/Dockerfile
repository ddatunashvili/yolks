# Forgejo for Pterodactyl / Wings.
#
# The official static binary from Codeberg on Debian, with git and git-lfs
# for the repositories it serves. Configuration, the SQLite database and the
# repositories all live under /home/container; forgejo-start writes app.ini
# on the first start and keeps the port and address in it current after.
FROM debian:bookworm-slim

ARG FORGEJO_VERSION=16.0.6
ARG TARGETARCH

LABEL org.opencontainers.image.source="https://github.com/ddatunashvili/yolks" \
      org.opencontainers.image.description="Forgejo ${FORGEJO_VERSION} for Pterodactyl" \
      org.opencontainers.image.licenses="MIT"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git git-lfs gnupg xz-utils tini tzdata iproute2 \
 && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
      amd64) arch=amd64 ;; \
      arm64) arch=arm64 ;; \
      *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    base="https://codeberg.org/forgejo/forgejo/releases/download/v${FORGEJO_VERSION}"; \
    file="forgejo-${FORGEJO_VERSION}-linux-${arch}.xz"; \
    cd /tmp; \
    curl -fsSL -o "$file" "${base}/${file}"; \
    curl -fsSL -o "$file.sha256" "${base}/${file}.sha256"; \
    sha256sum -c "$file.sha256"; \
    xz -d "$file"; \
    install -m 0755 "forgejo-${FORGEJO_VERSION}-linux-${arch}" /usr/local/bin/forgejo; \
    rm -f /tmp/forgejo-*; \
    forgejo --version

RUN useradd -m -d /home/container -s /bin/bash container

COPY entrypoint.sh /entrypoint.sh
COPY forgejo-start /usr/local/bin/forgejo-start
RUN chmod 0755 /entrypoint.sh /usr/local/bin/forgejo-start

USER container
ENV USER=container HOME=/home/container \
    GITEA_WORK_DIR=/home/container \
    FORGEJO_WORK_DIR=/home/container
WORKDIR /home/container

STOPSIGNAL SIGINT
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
