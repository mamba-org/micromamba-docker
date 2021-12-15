setup_file() {
    load 'test_helper/common-setup'
    _common_setup

    if [ -z "${MICROMAMBA_VERSION}" ]; then
      export MICROMAMBA_VERSION="$(./check_version.py 2> /dev/null | cut -f1 -d,)"
    fi

    # only used for building the micromamba image, not derived images
    MICROMAMBA_FLAGS="--build-arg VERSION=${MICROMAMBA_VERSION}"

    docker build $MICROMAMBA_FLAGS \
                 --quiet \
                 --tag=micromamba:test \
		 --file=${PROJECT_ROOT}/Dockerfile \
		 "$PROJECT_ROOT" > /dev/null
    docker build --quiet \
                 --tag=new-user \
		 --file=${PROJECT_ROOT}/test/new-user.Dockerfile \
		 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}


# Simulate TTY input for the docker run command
# https://stackoverflow.com/a/20401674
faketty() {
    script --return --quiet --flush --command "$(printf "%q " "$@")" /dev/null
}

# Test .bashrc activation for a fresh user by disabling the entrypoint script.
@test "'docker run --rm -it --entrypoint=/bin/bash new-user' with 'python --version; exit'" {
    input="python --version; exit"
    echo -e $input | faketty \
        docker run --rm -it --entrypoint=/bin/bash new-user

    # Make sure that a similar command actually fails
    input="xyz --version; exit"
    ! echo -e $input | faketty \
        docker run --rm -it --entrypoint=/bin/bash new-user
}
