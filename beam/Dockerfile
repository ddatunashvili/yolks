# BEAM runtime (Erlang/OTP + Elixir + Gleam) for Pterodactyl / Wings.
#
# One image per OTP major, picked by BASE: hexpm's prebuilt Elixir images are
# Debian bookworm-slim with Erlang and Elixir compiled for amd64 and arm64,
# which saves building OTP from source under QEMU. Gleam, rebar3 and Node LTS
# are added on top: rebar3 because Gleam builds rebar3 Hex packages with it,
# Node because Gleam's javascript target runs on it and many Phoenix asset
# pipelines still call npm.
ARG BASE=hexpm/elixir:1.20.4-erlang-29.1.2-debian-bookworm-20261005-slim
FROM ${BASE}

ARG GLEAM_VERSION=1.19.2
ARG REBAR3_VERSION=3.27.3
ARG NODE_VERSION=24.22.0
ARG TARGETARCH

LABEL org.opencontainers.image.source="https://github.com/ddatunashvili/yolks" \
      org.opencontainers.image.description="Erlang/OTP, Elixir and Gleam for Pterodactyl" \
      org.opencontainers.image.licenses="MIT"

USER root
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git xz-utils tini tzdata iproute2 build-essential \
 && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    case "${TARGETARCH:-amd64}" in \
      amd64) garch=x86_64; narch=x64 ;; \
      arm64) garch=aarch64; narch=arm64 ;; \
      *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://github.com/gleam-lang/gleam/releases/download/v${GLEAM_VERSION}/gleam-v${GLEAM_VERSION}-${garch}-unknown-linux-musl.tar.gz" \
      | tar -xz -C /usr/local/bin gleam; \
    curl -fsSL -o /usr/local/bin/rebar3 "https://github.com/erlang/rebar3/releases/download/${REBAR3_VERSION}/rebar3"; \
    chmod 0755 /usr/local/bin/rebar3 /usr/local/bin/gleam; \
    mkdir -p /opt/node; \
    curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${narch}.tar.xz" \
      | tar -xJ -C /opt/node --strip-components=1; \
    ln -s /opt/node/bin/node /usr/local/bin/node; \
    ln -s /opt/node/bin/npm /usr/local/bin/npm; \
    ln -s /opt/node/bin/npx /usr/local/bin/npx; \
    elixir --version; gleam --version; rebar3 version; node --version

RUN useradd -m -d /home/container -s /bin/bash container

COPY entrypoint.sh /entrypoint.sh
COPY elixir-start /usr/local/bin/elixir-start
COPY gleam-start /usr/local/bin/gleam-start
RUN chmod 0755 /entrypoint.sh /usr/local/bin/elixir-start /usr/local/bin/gleam-start

USER container
ENV USER=container HOME=/home/container \
    LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    MIX_HOME=/home/container/.mix HEX_HOME=/home/container/.hex \
    npm_config_cache=/home/container/.npm
WORKDIR /home/container

# SIGTERM, not SIGINT: the BEAM answers SIGINT with its interactive BREAK
# menu and waits for a key, while SIGTERM runs init:stop() and shuts the
# application down cleanly. Wings' "^C" stop sends the image's stop signal.
STOPSIGNAL SIGTERM
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
