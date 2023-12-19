#!/usr/bin/env bash

set -euo pipefail

for app in $(find ./bin/ -mindepth 1 -maxdepth 1 -executable)
do
  echo Starting: $app
  "$app" >/dev/null &
done

while true
do
  sleep 1
done
