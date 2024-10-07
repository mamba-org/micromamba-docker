# shellcheck disable=SC2317 # bats test make some code appear unreachable

setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 "--build-arg=BASE_IMAGE=${MICROMAMBA_IMAGE}" \
                 "--platform=${DOCKER_PLATFORM}" \
                 "--tag=${MICROMAMBA_IMAGE}-multi-env" \
		 "--file=${PROJECT_ROOT}/test/multi-env.Dockerfile" \
		 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "docker run -e ENV_NAME=env1 ${MICROMAMBA_IMAGE}-multi-env curl --version" {
    run docker run --rm "--platform=${DOCKER_PLATFORM}"  -e ENV_NAME=env1 "${MICROMAMBA_IMAGE}-multi-env" curl --version
    assert_output  --partial 'curl 7.71.1'
}

@test "docker run -e ENV_NAME=env2 ${MICROMAMBA_IMAGE}-multi-env jq --version" {
    run docker run --rm "--platform=${DOCKER_PLATFORM}" -e ENV_NAME=env2 "${MICROMAMBA_IMAGE}-multi-env" jq --version
    assert_output 'jq-1.6'
}
