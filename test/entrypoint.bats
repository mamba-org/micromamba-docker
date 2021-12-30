setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 --tag=entrypoint \
		 --file=${PROJECT_ROOT}/test/entrypoint.Dockerfile \
		 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "docker run --rm  entrypoint -c 'import sys; print(sys.version_info[0])'" {
    run docker run --rm  entrypoint -c 'import sys; print(sys.version_info[0])'
    assert_output '3'
}
