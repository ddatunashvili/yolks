# Dart runtime for Pterodactyl / Wings.
#
# One image per stable Dart SDK, picked by DART_VERSION, from Google's own
# archive (x64 and arm64 zips). `dart compile exe` needs nothing else; git is
# for git dependencies in pubspec.yaml.
FROM debian:bookworm-slim

ARG DART_VERSION=3.13.5
ARG TARGETARCH

LABEL org.opencontainers.image.source="https://github.com/ddatunashvili/yolks" \
      org.opencontainers.image.description="Dart ${DART_VERSION} for Pterodactyl" \
      org.opencontainers.image.licenses="MIT"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git unzip tini tzdata iproute2 \
 && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
      amd64) arch=x64 ;; \
      arm64) arch=arm64 ;; \
      *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/dart.zip \
      "https://storage.googleapis.com/dart-archive/channels/stable/release/${DART_VERSION}/sdk/dartsdk-linux-${arch}-release.zip"; \
    unzip -q /tmp/dart.zip -d /opt; \
    rm /tmp/dart.zip; \
    chmod -R a+rX /opt/dart-sdk; \
    ln -s /opt/dart-sdk/bin/dart /usr/local/bin/dart; \
    dart --disable-analytics >/dev/null 2>&1 || true; \
    dart --version

RUN useradd -m -d /home/container -s /bin/bash container

COPY entrypoint.sh /entrypoint.sh
COPY dart-start /usr/local/bin/dart-start
RUN chmod 0755 /entrypoint.sh /usr/local/bin/dart-start

USER container
ENV USER=container HOME=/home/container \
    PUB_CACHE=/home/container/.pub-cache \
    PATH=/home/container/.pub-cache/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
WORKDIR /home/container

STOPSIGNAL SIGINT
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
