# Jellyfin for Pterodactyl / Wings.
#
# The official portable build (self-contained .NET, jellyfin-web included)
# plus the portable jellyfin-ffmpeg it transcodes with, on Debian. Config,
# data, cache, logs and the media library all live under /home/container;
# jellyfin-start keeps the HTTP port in network.xml on the allocation.
FROM debian:bookworm-slim

ARG JELLYFIN_VERSION=12.2
ARG FFMPEG_VERSION=8.1.3-1
ARG TARGETARCH

LABEL org.opencontainers.image.source="https://github.com/ddatunashvili/yolks" \
      org.opencontainers.image.description="Jellyfin ${JELLYFIN_VERSION} for Pterodactyl" \
      org.opencontainers.image.licenses="MIT"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl xz-utils tini tzdata iproute2 \
      libfontconfig1 fonts-dejavu-core libicu72 libssl3 \
 && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
      amd64) arch=amd64; ff=linux64 ;; \
      arm64) arch=arm64; ff=linuxarm64 ;; \
      *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/jellyfin.tar.gz \
      "https://repo.jellyfin.org/files/server/linux/stable/v${JELLYFIN_VERSION}/${arch}/jellyfin_${JELLYFIN_VERSION}-${arch}.tar.gz"; \
    mkdir -p /opt/jellyfin /opt/jellyfin-ffmpeg; \
    tar -xzf /tmp/jellyfin.tar.gz -C /opt/jellyfin --strip-components=1; \
    curl -fsSL -o /tmp/ffmpeg.tar.xz \
      "https://repo.jellyfin.org/files/ffmpeg/linux/${FFMPEG_VERSION%%.*}.x/${FFMPEG_VERSION}/${arch}/jellyfin-ffmpeg_${FFMPEG_VERSION}_portable_${ff}-gpl.tar.xz"; \
    tar -xJf /tmp/ffmpeg.tar.xz -C /opt/jellyfin-ffmpeg; \
    rm /tmp/jellyfin.tar.gz /tmp/ffmpeg.tar.xz; \
    test -x /opt/jellyfin/jellyfin; \
    /opt/jellyfin-ffmpeg/ffmpeg -hide_banner -version | head -1; \
    echo "${JELLYFIN_VERSION}" > /opt/jellyfin/.renode-version

RUN useradd -m -d /home/container -s /bin/bash container

COPY entrypoint.sh /entrypoint.sh
COPY jellyfin-start /usr/local/bin/jellyfin-start
RUN chmod 0755 /entrypoint.sh /usr/local/bin/jellyfin-start

USER container
ENV USER=container HOME=/home/container \
    JELLYFIN_DATA_DIR=/home/container/data \
    JELLYFIN_CONFIG_DIR=/home/container/config \
    JELLYFIN_CACHE_DIR=/home/container/cache \
    JELLYFIN_LOG_DIR=/home/container/log \
    JELLYFIN_WEB_DIR=/opt/jellyfin/jellyfin-web \
    JELLYFIN_FFMPEG=/opt/jellyfin-ffmpeg/ffmpeg
WORKDIR /home/container

STOPSIGNAL SIGINT
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
