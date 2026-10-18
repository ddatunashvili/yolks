# Zig runtime for Pterodactyl / Wings.
#
# One image per Zig release, picked by ZIG_VERSION. Zig ships its own C
# compiler and libc, so nothing beyond git (for `git+https` dependencies in
# build.zig.zon), curl and xz is needed to build a project from source.
FROM debian:bookworm-slim

ARG ZIG_VERSION=0.17.0
ARG TARGETARCH

LABEL org.opencontainers.image.source="https://github.com/ddatunashvili/yolks" \
      org.opencontainers.image.description="Zig ${ZIG_VERSION} for Pterodactyl" \
      org.opencontainers.image.licenses="MIT"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git xz-utils tini tzdata iproute2 \
 && rm -rf /var/lib/apt/lists/*

# Zig renamed its tarballs in 0.14.1 (zig-linux-x86_64 -> zig-x86_64-linux),
# so try the new name first and fall back to the old one.
RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
      amd64) arch=x86_64 ;; \
      arm64) arch=aarch64 ;; \
      *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    base="https://ziglang.org/download/${ZIG_VERSION}"; \
    curl -fsSL -o /tmp/zig.tar.xz "${base}/zig-${arch}-linux-${ZIG_VERSION}.tar.xz" \
      || curl -fsSL -o /tmp/zig.tar.xz "${base}/zig-linux-${arch}-${ZIG_VERSION}.tar.xz"; \
    mkdir -p /opt/zig; \
    tar -xJf /tmp/zig.tar.xz -C /opt/zig --strip-components=1; \
    rm /tmp/zig.tar.xz; \
    ln -s /opt/zig/zig /usr/local/bin/zig; \
    zig version

RUN useradd -m -d /home/container -s /bin/bash container

COPY entrypoint.sh /entrypoint.sh
COPY zig-start /usr/local/bin/zig-start
RUN chmod 0755 /entrypoint.sh /usr/local/bin/zig-start

USER container
ENV USER=container HOME=/home/container \
    ZIG_GLOBAL_CACHE_DIR=/home/container/.cache/zig
WORKDIR /home/container

STOPSIGNAL SIGINT
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
