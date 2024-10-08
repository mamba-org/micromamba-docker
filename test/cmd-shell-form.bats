# shellcheck disable=SC2317 # bats test make some code appear unreachable

setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    build_image cmd-shell-form.Dockerfile
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "CMD python -c \"print('hello')\"" {
    # shellcheck disable=SC2086
    run docker run $RUN_FLAGS "${MICROMAMBA_IMAGE}-cmd-shell-form"
    assert_output 'hello'
}

@test "CMD python -c \"print('hello')\" with --user" {
    # shellcheck disable=SC2086
    run docker run $RUN_FLAGS --user=1001:1001 "${MICROMAMBA_IMAGE}-cmd-shell-form"
    assert_output 'hello'
}
