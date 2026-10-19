# Nim runtime for Pterodactyl / Wings.
#
# One image per Nim release, picked by NIM_VERSION. Nim compiles to C, so the
# image carries gcc, and nimble fetches packages with git. libssl-dev is there
# because -d:ssl (httpclient, most web frameworks' TLS) links against it.
#
# nim-lang.org publishes prebuilt linux_x64 tarballs for every release and
# linux_arm64 ones for recent releases only; when the prebuilt one is missing
# the compiler is built from the source tarball instead.
FROM debian:bookworm-slim

ARG NIM_VERSION=2.2.12
ARG TARGETARCH

LABEL org.opencontainers.image.source="https://github.com/ddatunashvili/yolks" \
      org.opencontainers.image.description="Nim ${NIM_VERSION} for Pterodactyl" \
      org.opencontainers.image.licenses="MIT"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git xz-utils tini tzdata iproute2 \
      build-essential libssl-dev libpcre3 \
 && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
      amd64) arch=x64 ;; \
      arm64) arch=arm64 ;; \
      *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    base="https://nim-lang.org/download"; \
    mkdir -p /opt/nim; \
    if curl -fsSL -o /tmp/nim.tar.xz "${base}/nim-${NIM_VERSION}-linux_${arch}.tar.xz"; then \
      tar -xJf /tmp/nim.tar.xz -C /opt/nim --strip-components=1; \
    else \
      curl -fsSL -o /tmp/nim.tar.xz "${base}/nim-${NIM_VERSION}.tar.xz"; \
      tar -xJf /tmp/nim.tar.xz -C /opt/nim --strip-components=1; \
      cd /opt/nim; \
      sh build.sh; \
      ./bin/nim c -d:release --skipUserCfg --skipParentCfg --hints:off koch; \
      ./koch boot -d:release --skipUserCfg --skipParentCfg --hints:off; \
      ./koch tools --skipUserCfg --skipParentCfg --hints:off; \
      rm -rf c_code nimcache csources* build; \
    fi; \
    rm /tmp/nim.tar.xz; \
    for b in nim nimble; do ln -s "/opt/nim/bin/$b" "/usr/local/bin/$b"; done; \
    nim --version; nimble --version

RUN useradd -m -d /home/container -s /bin/bash container

COPY entrypoint.sh /entrypoint.sh
COPY nim-start /usr/local/bin/nim-start
RUN chmod 0755 /entrypoint.sh /usr/local/bin/nim-start

USER container
ENV USER=container HOME=/home/container \
    NIMBLE_DIR=/home/container/.nimble
WORKDIR /home/container

STOPSIGNAL SIGINT
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
