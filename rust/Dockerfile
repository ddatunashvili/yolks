# Rust runtime for Pterodactyl / Wings.
#
# One image per Rust minor, picked by RUST_VERSION ("1.99" installs the newest
# 1.99.x). The toolchain
# lives read-only under /usr/local; the cargo registry, git checkouts and the
# target directory live in /home/container so rebuilds are incremental.
FROM debian:bookworm-slim

ARG RUST_VERSION=1.99

LABEL org.opencontainers.image.source="https://github.com/ddatunashvili/yolks" \
      org.opencontainers.image.description="Rust ${RUST_VERSION} for Pterodactyl" \
      org.opencontainers.image.licenses="MIT"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git build-essential pkg-config libssl-dev \
      tini tzdata iproute2 \
 && rm -rf /var/lib/apt/lists/*

ENV RUSTUP_HOME=/usr/local/rustup \
    PATH=/usr/local/cargo/bin:$PATH

# rustup-init picks the right host triple itself; the minimal profile is
# rustc, cargo and rust-std, which is all a build needs.
RUN set -eux; \
    curl -fsSL https://sh.rustup.rs -o /tmp/rustup-init.sh; \
    CARGO_HOME=/usr/local/cargo sh /tmp/rustup-init.sh -y --no-modify-path \
        --profile minimal --default-toolchain "${RUST_VERSION}"; \
    rm /tmp/rustup-init.sh; \
    chmod -R a+rX /usr/local/rustup /usr/local/cargo; \
    rustc --version; cargo --version

RUN useradd -m -d /home/container -s /bin/bash container

COPY entrypoint.sh /entrypoint.sh
COPY rust-start /usr/local/bin/rust-start
RUN chmod 0755 /entrypoint.sh /usr/local/bin/rust-start

USER container
# RUSTUP_TOOLCHAIN pins the image's own toolchain: a rust-toolchain.toml in a
# project would otherwise make rustup try to install another one into the
# read-only RUSTUP_HOME and fail.
ENV USER=container HOME=/home/container \
    CARGO_HOME=/home/container/.cargo \
    RUSTUP_TOOLCHAIN=${RUST_VERSION} \
    CARGO_TERM_COLOR=always
WORKDIR /home/container

STOPSIGNAL SIGINT
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
