#!/usr/bin/env bash

echo "💼 Updating api / bind -> 0.0.0.0:33033"
sed -i "s/bind = \".*:33033\"/bind = \"0.0.0.0:33033\"/g" /massa/massa-node/config/config.toml

if [ "" = "$*" ] || [ "run-node.sh" = "$*" ]; then
  echo "🦄 Starting Massa Node"
  exec "run-node.sh"
else
  echo "🦄 Starting '$@'"
  exec "$@"
fi
