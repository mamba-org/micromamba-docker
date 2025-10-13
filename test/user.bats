# shellcheck disable=SC2317 # bats test make some code appear unreachable

custom_mamba_user_id=1100
custom_mamba_user_gid=2000

setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 "--tag=${MICROMAMBA_IMAGE}-modify-user-id-gid-base" \
                 "--build-arg=BASE_IMAGE=${BASE_IMAGE}" \
                 "--platform=${DOCKER_PLATFORM}" \
                 "--build-arg=MAMBA_USER_ID=$custom_mamba_user_id" \
                 "--build-arg=MAMBA_USER_GID=$custom_mamba_user_gid" \
                 "--file=${PROJECT_ROOT}/${DISTRO_ID}.Dockerfile" \
                 "$PROJECT_ROOT" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}


# Test that custom mamba user id and group id are set correctly for base image builds.
@test "docker run ${MICROMAMBA_IMAGE}-modify-user-id-gid-base id" {
        # shellcheck disable=SC2086
        run docker run $RUN_FLAGS "${MICROMAMBA_IMAGE}-modify-user-id-gid-base" bash -c 'cat /etc/group && id'
        assert_success
        assert_output "uid=1100(mambauser) gid=2000(mambauser) groups=2000(mambauser)"
}
