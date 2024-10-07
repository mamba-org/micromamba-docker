# shellcheck disable=SC2317 # bats test make some code appear unreachable

setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    build_image entrypoint.Dockerfile
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "docker run ${MICROMAMBA_IMAGE}-entrypoint -c 'import sys; print(sys.version_info[0])'" {
    # shellcheck disable=SC2086
    run docker run $RUN_FLAGS "${MICROMAMBA_IMAGE}-entrypoint" -c 'import sys; print(sys.version_info[0])'
    assert_output '3'
}
