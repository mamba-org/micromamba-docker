setup() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 --tag=micromamba:test \
		 --file=${PROJECT_ROOT}/Dockerfile \
		 "$PROJECT_ROOT" > /dev/null
    docker build --quiet \
                 --tag=cli-invocations \
		 --file=${PROJECT_ROOT}/test/cli-invocations.Dockerfile \
		 "${PROJECT_ROOT}/test" > /dev/null
}

@test "docker run --rm  cli-invocations python --version" {
    run docker run --rm  cli-invocations python --version
    assert_output 'Python 3.9.1'
}

@test "docker run --rm  --user=1001:1001 cli-invocations python --version" {
    run docker run --rm  --user=1001:1001 cli-invocations python --version
    assert_output 'Python 3.9.1'
}

@test "docker run --rm --entrypoint python cli-invocations --version" {
    run docker run --rm --entrypoint python cli-invocations --version
    assert_output 'Python 3.9.1'
}

@test "docker run --rm --user=1001:1001 --entrypoint python cli-invocations --version" {
    run docker run --rm --user=1001:1001 --entrypoint python cli-invocations --version
    assert_output 'Python 3.9.1'
}
