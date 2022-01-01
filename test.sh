#!/bin/bash
set -eu -o pipefail

export DOCKER_BUILDKIT=1

PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

function load { :; }  # common-setup.bash needs this defined
source "${PROJECT_ROOT}/test/test_helper/common-setup.bash"

# sets MICROMAMBA_VERSION
_get_micromamba_version

FLAGS=
if which parallel > /dev/null; then
  if [[ $(uname -s) == "Darwin" ]]; then
    NUM_CPUS=$(sysctl -n hw.ncpu)
  else
    NUM_CPUS=$(nproc)
  fi
  FLAGS="${FLAGS} --jobs ${NUM_CPUS}"
  if [ "$NUM_CPUS" -gt "1" ]; then
    PROJECT_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    # build main test image here so that each *.bats file doesn't do this work in
    # parallel. The *.bats files will still run this docker command, but it will
    # just be a cache hit.
    while read -r IMAGE_INFO; do
      IFS=';' read -ra IMAGE_ARRAY <<< "$IMAGE_INFO"
      BASE_IMAGE="${IMAGE_ARRAY[0]}"
      DEBIAN_NAME="${IMAGE_ARRAY[1]}"
      echo "BASE_IMAGE=$BASE_IMAGE ; DEBIAN_NAME=$DEBIAN_NAME"
      docker build --quiet \
	           --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
                   "--tag=micromamba:test-${DEBIAN_NAME}" \
                   "--file=${PROJECT_ROOT}/Dockerfile" \
                   "$PROJECT_ROOT" > /dev/null
    done < "${PROJECT_ROOT}/tags.tsv"
  fi
fi

./test/bats/bin/bats $FLAGS $@ test/wrapper.bats
