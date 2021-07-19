FROM alpine:3.13 as build-stage

ARG GIT_URL=https://gitlab.com/massalabs/massa.git
ARG RUST_VERSION=nightly
ARG RUST_BACKTRACE=full

ENV PATH=${PATH}:/root/.cargo/bin

# dependencies
RUN set -xe; \
  # build tools
  apk add --no-cache --virtual .build-deps \
  autoconf automake libtool make gcc libgcc musl-dev build-base curl git openssl openssl-dev; \
  # rust
  curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain none -y; \
  rustup install "$RUST_VERSION" && rustup default "$RUST_VERSION"; \
  source $HOME/.cargo/env; \
  # clone the repo
  git clone "$GIT_URL" /massa; \
  # build
  cd /massa/massa-node; cargo build --release; \
  cd /massa/massa-client; cargo build --release;
# remove our build dependencies 
# apk del .build-deps;

# Massa base image
FROM build-stage as massa

# install deps
RUN apk add --no-cache ca-certificates libgcc

# copy the binary 
COPY --from=build-stage /massa /massa

# Massa node
FROM massa as massa-node

WORKDIR /massa/massa-node

VOLUME /massa/massa-node/block_store
VOLUME /massa/massa-node/config

CMD ["cargo", "run", "--release"]

# Massals client
FROM massa as massa-client

COPY ./bin/massa.sh /usr/local/bin/massa

WORKDIR /massa/massa-client

VOLUME /massa/massa-client/config

CMD ["cargo", "run", "--release", "--", "--wallet", "./config/wallet.dat"]