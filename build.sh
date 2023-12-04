#!/usr/bin/env bash

set -euo pipefail

NAME=libbpf-bootstrap-static-docker

docker build -t ${NAME} .

rm -rf bin/
ID=$(docker create ${NAME} /bin/minimal)
docker cp ${ID}:/bin .
docker rm ${ID}
