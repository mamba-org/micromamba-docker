# shellcheck disable=SC2317 # bats test make some code appear unreachable

setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 "--build-arg=BASE_IMAGE=${MICROMAMBA_IMAGE}" \
                 "--platform=${DOCKER_PLATFORM}" \
                 "--tag=${MICROMAMBA_IMAGE}-entrypoint" \
		 "--file=${PROJECT_ROOT}/test/entrypoint.Dockerfile" \
		 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "docker run ${MICROMAMBA_IMAGE}-entrypoint -c 'import sys; print(sys.version_info[0])'" {
    run docker run --rm "--platform=${DOCKER_PLATFORM}" "${MICROMAMBA_IMAGE}-entrypoint" -c 'import sys; print(sys.version_info[0])'
    assert_output '3'
}
