# shellcheck disable=SC2317 # bats test make some code appear unreachable

setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 "--build-arg=BASE_IMAGE=${MICROMAMBA_IMAGE}" \
                 "--tag=${MICROMAMBA_IMAGE}-cli-invocations" \
		 "--file=${PROJECT_ROOT}/test/cli-invocations.Dockerfile" \
		 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "docker run --rm  ${MICROMAMBA_IMAGE}-cli-invocations python --version" {
    run docker run --rm  "${MICROMAMBA_IMAGE}-cli-invocations" python --version
    assert_output 'Python 3.9.1'
}

@test "docker run --rm  --user=1001:1001 ${MICROMAMBA_IMAGE}-cli-invocations python --version" {
    run docker run --rm  --user=1001:1001 "${MICROMAMBA_IMAGE}-cli-invocations" python --version
    assert_output 'Python 3.9.1'
}

@test "docker run --rm ${MICROMAMBA_IMAGE} micromamba install -y -n base -c conda-forge ca-certificates" {
    run docker run --rm "${MICROMAMBA_IMAGE}" micromamba install -y -n base -c conda-forge ca-certificates
    assert_output --partial 'Transaction finished'
}

@test "docker run --rm --user=1001:1001 ${MICROMAMBA_IMAGE} micromamba install -y -n base -c conda-forge ca-certificates" {
    run docker run --rm --user=1001:1001 "${MICROMAMBA_IMAGE}" micromamba install -y -n base -c conda-forge ca-certificates
    assert_output --partial 'Transaction finished'
}

@test "apptainer --silent run docker-daemon:${MICROMAMBA_IMAGE}-cli-invocations python --version" {
    which apptainer || skip 'apptainer not available'
    run apptainer --silent run docker-daemon:"${MICROMAMBA_IMAGE}-cli-invocations" python --version
    assert_output 'Python 3.9.1'
}

@test "apptainer --silent exec docker-daemon:${MICROMAMBA_IMAGE}-cli-invocations /usr/local/bin/_entrypoint.sh python --version" {
    which apptainer || skip 'apptainer not available'
    run apptainer --silent exec docker-daemon:"${MICROMAMBA_IMAGE}-cli-invocations" /usr/local/bin/_entrypoint.sh python --version
    assert_output 'Python 3.9.1'
}

@test "apptainer --silent shell --shell /usr/local/bin/_apptainer_shell.sh docker-daemon:${MICROMAMBA_IMAGE}-cli-invocations /usr/local/bin/_entrypoint.sh python --version" {
    which apptainer || skip 'apptainer not available'
    run apptainer --silent exec docker-daemon:"${MICROMAMBA_IMAGE}-cli-invocations" /usr/local/bin/_entrypoint.sh python --version
    assert_output 'Python 3.9.1'
}
