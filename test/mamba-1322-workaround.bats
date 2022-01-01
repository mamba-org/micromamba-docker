setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 --tag=micromamba:test-mamba-1322-workaround \
		 --file=${PROJECT_ROOT}/test/mamba-1322-workaround.Dockerfile \
		 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

# Test the workaround for <https://github.com/mamba-org/mamba/issues/1322> as described
# in <https://github.com/mamba-org/micromamba-docker/issues/57>.

@test "docker run --rm  micromamba:test-mamba-1322-workaround echo squeamish ossifrage" {
    run docker run --rm  micromamba:test-mamba-1322-workaround echo squeamish ossifrage
    assert_output "squeamish ossifrage"
}
