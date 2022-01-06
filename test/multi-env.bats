setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 --tag=micromamba:test-multi-env \
		 --file=${PROJECT_ROOT}/test/multi-env.Dockerfile \
		 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "docker run --rm  -e ENV_NAME=env1 micromamba:test-multi-env curl --version" {
    run docker run --rm  -e ENV_NAME=env1 micromamba:test-multi-env curl --version
    assert_output  --partial 'curl 7.71.1'
}

@test "docker run --rm -e ENV_NAME=env2 micromamba:test-multi-env jq --version" {
    run docker run --rm -e ENV_NAME=env2 micromamba:test-multi-env jq --version
    assert_output 'jq-1.6'
}
