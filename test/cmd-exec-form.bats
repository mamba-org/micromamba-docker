setup() {
    load 'test_helper/common-setup'
    _common_setup
    docker build -t micromamba:test -f ${PROJECT_ROOT}/Dockerfile "$PROJECT_ROOT"
    docker build -t cmd-exec-form  -f ${PROJECT_ROOT}/test/cmd-exec-form.Dockerfile "${PROJECT_ROOT}/test"
}

@test "CMD [\"/opt/conda/bin/python\", \"-c\", \"print('hello')\"]" {
    run docker run --rm cmd-exec-form
    assert_output 'hello'
}
