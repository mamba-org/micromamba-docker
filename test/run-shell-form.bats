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
                 --tag=run-shell-form \
		 --file=${PROJECT_ROOT}/test/run-shell-form.Dockerfile \
		 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "RUN python -c \"import os; os.system('touch foobar')\"" {
    run docker run --rm run-shell-form ls -1 foobar
    assert_output 'foobar'
}
