setup_file() {
    load 'test_helper/common-setup'
    _common_setup "cli-invocations"
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
