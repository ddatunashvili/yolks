# Crystal runtime for Pterodactyl / Wings.
#
# One image per Crystal release, picked by CRYSTAL_VERSION, from the official
# tarball on GitHub (compiler and shards). Crystal links
# against the system's C libraries at build time, so their headers are here:
# OpenSSL, PCRE2, libgc, libevent, libyaml, libxml2, zlib and GMP.
FROM debian:bookworm-slim

ARG CRYSTAL_VERSION=1.22.0
ARG TARGETARCH

LABEL org.opencontainers.image.source="https://github.com/ddatunashvili/yolks" \
      org.opencontainers.image.description="Crystal ${CRYSTAL_VERSION} for Pterodactyl" \
      org.opencontainers.image.licenses="MIT"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git gcc g++ make pkg-config \
      libssl-dev libpcre2-dev libgc-dev libevent-dev libyaml-dev \
      libxml2-dev zlib1g-dev libgmp-dev libsqlite3-dev libpq-dev \
      tini tzdata iproute2 \
 && rm -rf /var/lib/apt/lists/*

# The tarball's static libgc is built against a newer glibc than bookworm's
# (it wants __isoc23_strtol), so it is removed and Debian's libgc is linked.
RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
      amd64) arch=x86_64 ;; \
      arm64) arch=aarch64 ;; \
      *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/crystal.tar.gz \
      "https://github.com/crystal-lang/crystal/releases/download/${CRYSTAL_VERSION}/crystal-${CRYSTAL_VERSION}-1-linux-${arch}.tar.gz"; \
    mkdir -p /opt/crystal; \
    tar -xzf /tmp/crystal.tar.gz -C /opt/crystal --strip-components=1; \
    rm /tmp/crystal.tar.gz; \
    rm -f /opt/crystal/lib/crystal/libgc.a; \
    ln -s /opt/crystal/bin/crystal /usr/local/bin/crystal; \
    ln -s /opt/crystal/bin/shards /usr/local/bin/shards; \
    crystal --version; shards --version

RUN useradd -m -d /home/container -s /bin/bash container

COPY entrypoint.sh /entrypoint.sh
COPY crystal-start /usr/local/bin/crystal-start
RUN chmod 0755 /entrypoint.sh /usr/local/bin/crystal-start

USER container
ENV USER=container HOME=/home/container \
    CRYSTAL_CACHE_DIR=/home/container/.cache/crystal
WORKDIR /home/container

STOPSIGNAL SIGINT
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
