# shellcheck disable=SC2317 # bats test make some code appear unreachable

setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    build_image cli-invocations.Dockerfile
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "docker run ${MICROMAMBA_IMAGE}-cli-invocations python --version" {
    # shellcheck disable=SC2086
    run docker run $RUN_FLAGS "${MICROMAMBA_IMAGE}-cli-invocations" python --version
    assert_output 'Python 3.12.7'
}

@test "docker run --user=1001:1001 ${MICROMAMBA_IMAGE}-cli-invocations python --version" {
    # shellcheck disable=SC2086
    run docker run $RUN_FLAGS --user=1001:1001 "${MICROMAMBA_IMAGE}-cli-invocations" python --version
    assert_output 'Python 3.12.7'
}

@test "docker run ${MICROMAMBA_IMAGE} micromamba install -y -n base -c conda-forge ca-certificates" {
    # shellcheck disable=SC2086
    run docker run $RUN_FLAGS "${MICROMAMBA_IMAGE}" micromamba install -y -n base -c conda-forge ca-certificates
    assert_output --partial 'Transaction finished'
}

@test "docker run --user=1001:1001 ${MICROMAMBA_IMAGE} micromamba install -y -n base -c conda-forge ca-certificates" {
    # shellcheck disable=SC2086
    run docker run $RUN_FLAGS --user=1001:1001 "${MICROMAMBA_IMAGE}" micromamba install -y -n base -c conda-forge ca-certificates
    assert_output --partial 'Transaction finished'
}

@test "apptainer --silent run docker-daemon:${MICROMAMBA_IMAGE}-cli-invocations python --version" {
    which apptainer || skip 'apptainer not available'
    run apptainer --silent run docker-daemon:"${MICROMAMBA_IMAGE}-cli-invocations" python --version
    assert_output 'Python 3.12.7'
}

@test "apptainer --silent exec docker-daemon:${MICROMAMBA_IMAGE}-cli-invocations /usr/local/bin/_entrypoint.sh python --version" {
    which apptainer || skip 'apptainer not available'
    run apptainer --silent exec docker-daemon:"${MICROMAMBA_IMAGE}-cli-invocations" /usr/local/bin/_entrypoint.sh python --version
    assert_output 'Python 3.12.7'
}

@test "apptainer --silent shell --shell /usr/local/bin/_apptainer_shell.sh docker-daemon:${MICROMAMBA_IMAGE}-cli-invocations /usr/local/bin/_entrypoint.sh python --version" {
    which apptainer || skip 'apptainer not available'
    run apptainer --silent exec docker-daemon:"${MICROMAMBA_IMAGE}-cli-invocations" /usr/local/bin/_entrypoint.sh python --version
    assert_output 'Python 3.12.7'
}
