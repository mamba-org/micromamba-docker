# shellcheck disable=SC2317 # bats test make some code appear unreachable

default_mamba_user="mambauser"
altered_mamba_user="MaMbAmIcRo"
custom_mamba_user_id=1100
custom_mamba_user_gid=2000

setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 "--tag=${MICROMAMBA_IMAGE}-different-user" \
                 "--build-arg=BASE_IMAGE=${BASE_IMAGE}" \
                 "--build-arg=MAMBA_USER=$altered_mamba_user" \
                 "--build-arg=MAMBA_USER_ID=${MAMBA_USER_ID}" \
                 "--build-arg=MAMBA_USER_GID=${MAMBA_USER_GID}" \
                 "--file=${PROJECT_ROOT}/Dockerfile" \
                 "$PROJECT_ROOT" > /dev/null
    docker build --quiet \
                 "--tag=${MICROMAMBA_IMAGE}-modify-user-id-gid-base" \
                 "--build-arg=BASE_IMAGE=${BASE_IMAGE}" \
                 "--build-arg=MAMBA_USER_ID=$custom_mamba_user_id" \
                 "--build-arg=MAMBA_USER_GID=$custom_mamba_user_gid" \
                 "--file=${PROJECT_ROOT}/Dockerfile" \
                 "$PROJECT_ROOT" > /dev/null
    docker build --quiet \
                 "--tag=${MICROMAMBA_IMAGE}-modify-username" \
                 "--build-arg=BASE_IMAGE=${MICROMAMBA_IMAGE}" \
                 "--build-arg=MAMBA_USER_ID=$custom_mamba_user_id" \
                 "--build-arg=NEW_MAMBA_USER=$altered_mamba_user" \
                 "--build-arg=NEW_MAMBA_USER_ID=$custom_mamba_user_id" \
                 "--build-arg=NEW_MAMBA_USER_GID=$custom_mamba_user_gid" \
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
    [ "$output" = 'whoami: cannot find name for user ID 1001' ] \
    || [ "$output" = 'whoami: unknown uid 1001' ]
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

# Test that home is moved when modifying the username.
@test "docker run --rm -e MAMBA_USER=$altered_mamba_user ${MICROMAMBA_IMAGE}-modify-username bash -c \"realpath ~${altered_mamba_user}\"" {
        run docker run --rm -e "MAMBA_USER=$altered_mamba_user" "${MICROMAMBA_IMAGE}-modify-username" bash -c "realpath ~${altered_mamba_user}"
        assert_success
        assert_output "/home/$altered_mamba_user"
}

# Test that custom mamba user id and group id are set correctly for base image builds.
@test "docker run --rm ${MICROMAMBA_IMAGE}-modify-user-id-gid-base id" {
        run docker run --rm "${MICROMAMBA_IMAGE}-modify-user-id-gid-base" id
        assert_success
        assert_output "uid=1100(mambauser) gid=2000(mambauser) groups=2000(mambauser)"
}

# Test that custom mamba user id and group id are set correctly for derived image builds.
@test "docker run --rm ${MICROMAMBA_IMAGE}-modify-username id" {
        run docker run --rm "${MICROMAMBA_IMAGE}-modify-username" id
        assert_success
        assert_output "uid=1100(MaMbAmIcRo) gid=2000(MaMbAmIcRo) groups=2000(MaMbAmIcRo)"
}
