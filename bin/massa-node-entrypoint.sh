#!/usr/bin/env bash

echo "💼 Updating api / bind -> 0.0.0.0:33033"
sed -i "s/bind = \".*:33033\"/bind = \"0.0.0.0:33033\"/g" /massa/massa-node/config/config.toml

if [ "" = "$*" ] || [ "massa-node" = "$*" ]; then
  echo "🦄 Starting Massa Node"
  exec "massa-node"
else
  echo "🦄 Starting '$@'"
  exec "$@"
fi
