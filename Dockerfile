FROM phusion/baseimage:focal-1.0.0 as massa-build

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
  git clone "$GIT_URL" /massa; \
  # build node
  cd /massa/massa-node; cargo build --release -Z unstable-options --out-dir .; \
  # build client
  cd /massa/massa-client; cargo build --release -Z unstable-options --out-dir .;

# Massa client
FROM phusion/baseimage:focal-1.0.0 as massa-base

WORKDIR /massa

# now copy from the build stage into this image
COPY --from=massa-build /massa/massa-client/massa-client /usr/local/bin/massa-client
COPY --from=massa-build /massa/massa-client/config /massa/massa-client/config

COPY --from=massa-build /massa/massa-node/massa-node /usr/local/bin/massa-node
COPY --from=massa-build /massa/massa-node/config /massa/massa-node/config

COPY ./bin/* /massa

FROM massa-base as massa-client

WORKDIR /massa/massa-client

VOLUME /massa/massa-client/config

ENTRYPOINT [ "/massa/massa-client-entrypoint.sh" ]

CMD ["/massa/massa-client.sh"]

# Massa node
FROM massa-base as massa-node

VOLUME /massa/massa-node/block_store
VOLUME /massa/massa-node/config

ENTRYPOINT [ "/massa/massa-node-entrypoint.sh" ]

CMD ["/massa/massa-node.sh"]