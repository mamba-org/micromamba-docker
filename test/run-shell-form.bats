# shellcheck disable=SC2317 # bats test make some code appear unreachable

setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    build_image run-shell-form.Dockerfile
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "RUN python -c \"import os; os.system('touch foobar')\"" {
    # shellcheck disable=SC2086
    run docker run $RUN_FLAGS "${MICROMAMBA_IMAGE}-run-shell-form" ls -1 foobar
    assert_output 'foobar'
}
