# shellcheck disable=SC2317 # bats test make some code appear unreachable

setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 "--build-arg=BASE_IMAGE=${MICROMAMBA_IMAGE}" \
                 "--platform=${DOCKER_PLATFORM}" \
                 "--tag=${MICROMAMBA_IMAGE}-new-user" \
		 "--file=${PROJECT_ROOT}/test/new-user.Dockerfile" \
		 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

# Test .bashrc activation for a fresh user by disabling the entrypoint script.
@test "'docker run -it --entrypoint=/bin/bash ${MICROMAMBA_IMAGE}-new-user' with 'python --version; exit'" {
    f() {
        echo -e "$1" | faketty \
            docker run --rm "--platform=${DOCKER_PLATFORM}" -it --entrypoint=/bin/bash "${MICROMAMBA_IMAGE}-new-user"
    }
    run f 'python --version; exit'
    # Make sure that a similar command actually fails
    run ! f 'xyz --version; exit'
}
