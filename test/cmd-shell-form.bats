setup_file() {
    load 'test_helper/common-setup'
    _common_setup

    if [ -z "${MICROMAMBA_VERSION+x}" ]; then
      MICROMAMBA_VERSION="$(./check_version.py 2> /dev/null | cut -f1 -d,)"
    fi

    # only used for building the micromamba image, not derived images
    MICROMAMBA_FLAGS="--build-arg VERSION=${MICROMAMBA_VERSION}"

    docker build $MICROMAMBA_FLAGS \
                 --quiet \
                 --tag=micromamba:test \
		 --file=${PROJECT_ROOT}/Dockerfile \
		 "$PROJECT_ROOT" > /dev/null
    docker build --quiet \
                 --tag=cmd-shell-form \
		 --file=${PROJECT_ROOT}/test/cmd-shell-form.Dockerfile \
		 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "CMD python -c \"print('hello')\"" {
    run docker run --rm cmd-shell-form
    assert_output 'hello'
}

@test "CMD python -c \"print('hello')\" with --user" {
    run docker run --rm --user=1001:1001 cmd-shell-form
    assert_output 'hello'
}
