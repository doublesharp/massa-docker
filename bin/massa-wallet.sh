#!/usr/bin/env bash

cd /massa/massa-client
RUST_BACKTRACE=full cargo run --release -- --wallet ./config/wallet.dat
