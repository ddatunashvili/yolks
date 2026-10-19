# Ruby runtime for Pterodactyl / Wings.
#
# One image per Ruby minor, picked by RUBY_VERSION. Built on the official
# ruby:<minor>-slim-bookworm image (debian:bookworm-slim with Ruby compiled
# into /usr/local), plus the headers native gems need: pg, mysql2, psych,
# sqlite3, nokogiri, bcrypt and friends.
ARG RUBY_VERSION=3.4
FROM ruby:${RUBY_VERSION}-slim-bookworm

ARG RUBY_VERSION

LABEL org.opencontainers.image.source="https://github.com/ddatunashvili/yolks" \
      org.opencontainers.image.description="Ruby ${RUBY_VERSION} for Pterodactyl" \
      org.opencontainers.image.licenses="MIT"

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl git build-essential pkg-config \
      libpq-dev default-libmysqlclient-dev libsqlite3-dev libyaml-dev \
      libffi-dev zlib1g-dev libssl-dev libxml2-dev libxslt1-dev \
      tini tzdata iproute2 \
 && rm -rf /var/lib/apt/lists/* \
 && ruby --version && bundle --version

RUN useradd -m -d /home/container -s /bin/bash container

COPY entrypoint.sh /entrypoint.sh
COPY ruby-start /usr/local/bin/ruby-start
RUN chmod 0755 /entrypoint.sh /usr/local/bin/ruby-start

USER container
# The official image points GEM_HOME and BUNDLE_APP_CONFIG at /usr/local/bundle,
# outside the volume. Gems installed by hand go to the home directory instead,
# and a project's own .bundle/config is honoured again.
ENV USER=container HOME=/home/container \
    GEM_HOME=/home/container/.gem \
    BUNDLE_APP_CONFIG=.bundle \
    PATH=/home/container/.gem/bin:/usr/local/bundle/bin:$PATH
WORKDIR /home/container

STOPSIGNAL SIGINT
ENTRYPOINT ["/usr/bin/tini", "-g", "--"]
CMD ["/entrypoint.sh"]
