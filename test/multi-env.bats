# shellcheck disable=SC2317 # bats test make some code appear unreachable

setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    build_image multi-env.Dockerfile
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "docker run -e ENV_NAME=env1 ${MICROMAMBA_IMAGE}-multi-env curl --version" {
    # shellcheck disable=SC2086
    run docker run $RUN_FLAGS  -e ENV_NAME=env1 "${MICROMAMBA_IMAGE}-multi-env" curl --version
    assert_output  --partial 'curl 7.71.1'
}

@test "docker run -e ENV_NAME=env2 ${MICROMAMBA_IMAGE}-multi-env jq --version" {
    # shellcheck disable=SC2086
    run docker run $RUN_FLAGS -e ENV_NAME=env2 "${MICROMAMBA_IMAGE}-multi-env" jq --version
    assert_output 'jq-1.6'
}
