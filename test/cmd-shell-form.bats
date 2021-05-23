setup() {
    load 'test_helper/common-setup'
    _common_setup
    docker build -t micromamba:test -f ${PROJECT_ROOT}/Dockerfile "$PROJECT_ROOT"
    docker build -t cmd-shell-form  -f ${PROJECT_ROOT}/test/cmd-shell-form.Dockerfile "${PROJECT_ROOT}/test"
}

@test "CMD python -c \"print('hello')\"" {
    run docker run --rm cmd-shell-form
    assert_output 'hello'
}
