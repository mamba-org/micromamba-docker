#!/bin/bash

set -euo pipefail

test "${TARGETARCH}" = 'amd64' && export ARCH='64'
test "${TARGETARCH}" = 'arm64' && export ARCH='aarch64'
test "${TARGETARCH}" = 'ppc64le' && export ARCH='ppc64le'
curl -L "https://micro.mamba.pm/api/micromamba/linux-${ARCH}/${VERSION}" \
| tar -xj -C "/" "bin/micromamba"
