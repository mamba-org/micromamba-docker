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
                 --tag=cli-invocations \
		 --file=${PROJECT_ROOT}/test/cli-invocations.Dockerfile \
		 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "docker run --rm  cli-invocations python --version" {
    run docker run --rm  cli-invocations python --version
    assert_output 'Python 3.9.1'
}

@test "docker run --rm  --user=1001:1001 cli-invocations python --version" {
    run docker run --rm  --user=1001:1001 cli-invocations python --version
    assert_output 'Python 3.9.1'
}

@test "docker run --rm micromamba:test micromamba install -y -n base -c conda-forge ca-certificates" {
    run docker run --rm micromamba:test micromamba install -y -n base -c conda-forge ca-certificates
    assert_output --partial 'Transaction finished'
}

@test "docker run --rm --user=1001:1001 micromamba:test micromamba install -y -n base -c conda-forge ca-certificates" {
    run docker run --rm --user=1001:1001 micromamba:test micromamba install -y -n base -c conda-forge ca-certificates
    assert_output --partial 'Transaction finished'
}
