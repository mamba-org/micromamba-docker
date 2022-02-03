setup_file() {
    load 'test_helper/common-setup'
    _common_setup
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "docker run --rm ${MICROMAMBA_IMAGE} whoami" {
    run docker run --rm "${MICROMAMBA_IMAGE}" whoami
    assert_output 'micromamba'
}

@test "docker run --rm --user=1001:1001 ${MICROMAMBA_IMAGE} whoami" {
    run docker run --rm --user=1001:1001 "${MICROMAMBA_IMAGE}" whoami
    assert_output 'whoami: cannot find name for user ID 1001'
}

@test "docker run --rm --user=root ${MICROMAMBA_IMAGE} whoami" {
    run docker run --rm --user=root "${MICROMAMBA_IMAGE}" whoami
    assert_output 'root'
}

@test "docker run --rm --user=0:0 ${MICROMAMBA_IMAGE} whoami" {
    run docker run --rm --user=0:0 "${MICROMAMBA_IMAGE}" whoami
    assert_output 'root'
}

@test "docker run --rm ${MICROMAMBA_IMAGE} /bin/bash -c 'realpath ~'" {
    run docker run --rm "${MICROMAMBA_IMAGE}" /bin/bash -c 'realpath ~'
    assert_output '/home/micromamba'
}

@test "docker run --rm --user=1001:1001 ${MICROMAMBA_IMAGE} /bin/bash -c 'realpath ~'" {
    run docker run --rm --user=1001:1001 "${MICROMAMBA_IMAGE}" /bin/bash -c 'realpath ~'
    assert_output '/home/micromamba'
}

@test "docker run --rm --user=root ${MICROMAMBA_IMAGE} /bin/bash -c 'realpath ~'" {
    run docker run --rm --user=root "${MICROMAMBA_IMAGE}" /bin/bash -c 'realpath ~'
    assert_output '/root'
}
