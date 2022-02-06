default_mamba_user="mambauser"
altered_mamba_user="MaMbAmIcRo"

setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 "--tag=${MICROMAMBA_IMAGE}-different-user" \
		 "--build-arg=BASE_IMAGE=${MICROMAMBA_IMAGE}" \
                 "--build-arg=MAMBA_USER=$altered_mamba_user" \
		 "--file=${PROJECT_ROOT}/Dockerfile" \
		 "$PROJECT_ROOT" > /dev/null
    docker build --quiet \
                 "--tag=${MICROMAMBA_IMAGE}-modify-username" \
                 "--build-arg=NEW_MAMBA_USER=$altered_mamba_user" \
		 "--file=${PROJECT_ROOT}/test/modify-username.Dockerfile" \
		 "$PROJECT_ROOT" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "docker run --rm ${MICROMAMBA_IMAGE} whoami" {
    run docker run --rm "${MICROMAMBA_IMAGE}" whoami
    assert_output "$default_mamba_user"
}

@test "docker run --rm ${MICROMAMBA_IMAGE}-different-user whoami" {
    run docker run --rm "${MICROMAMBA_IMAGE}-different-user" whoami
    assert_output "$altered_mamba_user"
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
    assert_output "/home/$default_mamba_user"
}

@test "docker run --rm --user=1001:1001 ${MICROMAMBA_IMAGE} /bin/bash -c 'realpath ~'" {
    run docker run --rm --user=1001:1001 "${MICROMAMBA_IMAGE}" /bin/bash -c 'realpath ~'
    assert_output "/home/$default_mamba_user"
}

@test "docker run --rm --user=root ${MICROMAMBA_IMAGE} /bin/bash -c 'realpath ~'" {
    run docker run --rm --user=root "${MICROMAMBA_IMAGE}" /bin/bash -c 'realpath ~'
    assert_output '/root'
}

# Test that naively modifying MAMBA_USER leads to an error.
@test "docker run --rm -e MAMBA_USER=$altered_mamba_user ${MICROMAMBA_IMAGE} whoami" {
        run docker run --rm -e "MAMBA_USER=$altered_mamba_user" "${MICROMAMBA_IMAGE}" whoami
        assert_failure
        assert_output --partial "ERROR: This micromamba-docker image was built with 'ARG MAMBA_USER="
}

# Test the approved method of modifying the username.
@test "docker run --rm -e MAMBA_USER=$altered_mamba_user ${MICROMAMBA_IMAGE}-modify-username whoami" {
        run docker run --rm -e "MAMBA_USER=$altered_mamba_user" "${MICROMAMBA_IMAGE}-modify-username" whoami
        assert_success
        assert_output "$altered_mamba_user"
}
