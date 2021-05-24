#!/bin/bash
set -eu -o pipefail

FLAGS=
if which parallel > /dev/null; then
  if [[ $(uname -s) == "Darwin" ]]; then
    NUM_CPUS=$(sysctl -n hw.ncpu)
  else
    NUM_CPUS=$(nproc)
  fi
  FLAGS="--jobs $NUM_CPUS"
  if [ "$NUM_CPUS" -gt "1" ]; then
    PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    # build main test image here so that each *.bats file doesn't do this work in
    # parallel. The *.bats files will still run this docker command, but it will
    # just be a cache hit.
    docker build --quiet \
                 --tag=micromamba:test \
                 "--file=${PROJECT_ROOT}/Dockerfile" \
                 "$PROJECT_ROOT" > /dev/null
  fi
fi

./test/bats/bin/bats $FLAGS $@ test/
