setup() {
    load 'test_helper/common-setup'
    _common_setup
    docker build -t micromamba:test -f ${PROJECT_ROOT}/Dockerfile "$PROJECT_ROOT"
    docker build -t cli-invocations  -f ${PROJECT_ROOT}/test/cli-invocations.Dockerfile "${PROJECT_ROOT}/test"
}

@test "docker run --rm  cli-invocations python --version" {
    run docker run --rm  cli-invocations python --version
    assert_output 'Python 3.9.1'
}

@test "docker run --rm --entrypoint python cli-invocations --version" {
    run docker run --rm --entrypoint python cli-invocations --version
    assert_output 'Python 3.9.1'
}
