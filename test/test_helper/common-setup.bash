#!/usr/bin/env bash

_common_setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." >/dev/null 2>&1 && pwd )"

    if [ -z "${MICROMAMBA_VERSION+x}" ]; then
      MICROMAMBA_VERSION="$("${PROJECT_ROOT}/check_version.py" 2> /dev/null | cut -f1 -d,)"
      export MICROMAMBA_VERSION
    fi
    # only used for building the micromamba image, not derived images
    MICROMAMBA_FLAGS="--build-arg VERSION=${MICROMAMBA_VERSION}"

    docker build $MICROMAMBA_FLAGS \
                 --quiet \
                 --tag=micromamba:test \
		 "--file=${PROJECT_ROOT}/Dockerfile" \
		 "$PROJECT_ROOT" > /dev/null
}
