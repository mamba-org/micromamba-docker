#!/bin/bash
set -eu -o pipefail

export DOCKER_BUILDKIT=1

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function load { :; }  # common-setup.bash needs this defined
source "${PROJECT_ROOT}/test/test_helper/common-setup.bash"

FLAGS=
if which parallel > /dev/null; then
  if [[ $(uname -s) == "Darwin" ]]; then
    NUM_CPUS=$(sysctl -n hw.ncpu)
  else
    NUM_CPUS=$(nproc)
  fi
  FLAGS="${FLAGS} --jobs ${NUM_CPUS}"
fi

./test/bats/bin/bats $FLAGS $@ test/
