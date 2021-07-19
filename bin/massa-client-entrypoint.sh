#!/usr/bin/env bash

HOST_IP=$(getent hosts node | awk '{ print $1 }' | xargs)
echo "💼 Updating node -> $HOST_IP"
sed -i "s/\".*:/\"$HOST_IP:/g" /massa/massa-client/config/config.toml

if [ "" = "$*" ] || [ "run-client.sh" = "$*" ]; then
  echo "🦄 Starting Massa Wallet"
  exec "run-client.sh"
else
  echo "🦄 Starting '$@'"
  exec "$@"
fi
