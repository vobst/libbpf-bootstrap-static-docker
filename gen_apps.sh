#!/usr/bin/env bash

set -euo pipefail

NEW_APPS="$(find . -maxdepth 1 -name '*.bpf.c' | sed -nr 's/^\.\/(.*?)\.bpf\.c$/\1/p' | xargs echo)"

sed -r -i "s/APPS = .*?/APPS = ${NEW_APPS}/" Makefile
