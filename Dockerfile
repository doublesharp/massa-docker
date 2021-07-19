FROM phusion/baseimage:focal-1.0.0 as massa-base

ARG GIT_URL=https://gitlab.com/massalabs/massa.git
ARG RUST_VERSION=nightly
ARG RUST_BACKTRACE=full

ARG DEBIAN_FRONTEND=noninteractive

ENV PATH=${PATH}:/root/.cargo/bin

# dependencies
RUN set -xe; \
  # build tools
  apt update; \
  apt install -y bash pkg-config curl git build-essential libssl-dev; \
  # rust
  curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain none -y; \
  rustup install "$RUST_VERSION" && rustup default "$RUST_VERSION"; \
  # clone the repo
  git clone "$GIT_URL" /massa;

# Massa client
FROM massa-base as massa-client

WORKDIR /massa/massa-client

RUN set -xe; \
  # build
  cargo build --release; 

COPY ./bin/massa-client-entrypoint.sh /usr/local/bin/massa-client-entrypoint.sh
COPY ./bin/massa-wallet.sh /usr/local/bin/massa-wallet

VOLUME /massa/massa-client/config

ENTRYPOINT [ "massa-client-entrypoint.sh" ]

CMD ["massa-wallet"]

# Massa node
FROM massa-base as massa-node

WORKDIR /massa/massa-node

RUN set -xe; \
  # build
  cargo build --release; 

COPY ./bin/massa-node-entrypoint.sh /usr/local/bin/massa-node-entrypoint.sh
COPY ./bin/massa-node.sh /usr/local/bin/massa-node

VOLUME /massa/massa-node/block_store
VOLUME /massa/massa-node/config

ENTRYPOINT [ "massa-node-entrypoint.sh" ]

CMD ["massa-node"]