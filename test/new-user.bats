# shellcheck disable=SC2317 # bats test make some code appear unreachable

setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    build_image new-user.Dockerfile
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

# Test .bashrc activation for a fresh user by disabling the entrypoint script.
@test "'docker run -it --entrypoint=/bin/bash ${MICROMAMBA_IMAGE}-new-user' with 'python --version; exit'" {
    f() {
        # shellcheck disable=SC2086
        echo -e "$1" | faketty \
            docker run $RUN_FLAGS -it --entrypoint=/bin/bash "${MICROMAMBA_IMAGE}-new-user"
    }
    run f 'python --version; exit'
    # Make sure that a similar command actually fails
    run ! f 'xyz --version; exit'
}
