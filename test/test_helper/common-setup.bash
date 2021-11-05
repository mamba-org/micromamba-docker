#!/usr/bin/env bash

_common_setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    TEST_NAME="$1"
    PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." >/dev/null 2>&1 && pwd )"
    PATH="$PROJECT_ROOT/src:$PATH"
    while read -r IMAGE_INFO; do
        IFS=';' read -ra IMAGE_ARRAY <<< "$IMAGE_INFO"
        BASE_IMAGE="${IMAGE_ARRAY[0]}"
        DEBIAN_NAME="${IMAGE_ARRAY[1]}"
	echo "TEST_NAME=$TEST_NAME BASE_IMAGE=$BASE_IMAGE, DEBIAN_NAME=$DEBIAN_NAME"
        docker build --quiet \
                     --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
                     "--tag=micromamba:test-${DEBIAN_NAME}" \
                     "--file=${PROJECT_ROOT}/Dockerfile" \
                     "$PROJECT_ROOT" > /dev/null
        docker build --quiet \
                     --build-arg "BASE_IMAGE=micromamba:test-${DEBIAN_NAME}" \
                     "--tag=${TEST_NAME}" \
		     "--file=${PROJECT_ROOT}/test/${TEST_NAME}.Dockerfile" \
		     "${PROJECT_ROOT}/test" > /dev/null
    done < "${PROJECT_ROOT}/tags.tsv"
}
