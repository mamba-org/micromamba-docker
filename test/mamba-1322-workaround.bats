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
                 --tag=mamba-1322-workaround \
		 --file=${PROJECT_ROOT}/test/mamba-1322-workaround.Dockerfile \
		 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

# Test the workaround for <https://github.com/mamba-org/mamba/issues/1322> as described
# in <https://github.com/mamba-org/micromamba-docker/issues/57>.

@test "docker run --rm  mamba-1322-workaround echo squeamish ossifrage" {
    run docker run --rm  mamba-1322-workaround echo squeamish ossifrage
    assert_output "squeamish ossifrage"
}
