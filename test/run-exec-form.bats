setup() {
    load 'test_helper/common-setup'
    _common_setup
    docker build -t micromamba:test -f ${PROJECT_ROOT}/Dockerfile "$PROJECT_ROOT"
    docker build -t run-exec-form  -f ${PROJECT_ROOT}/test/run-exec-form.Dockerfile "${PROJECT_ROOT}/test"
}

@test "RUN [\"python\", \"-c\", \"import os; os.system('touch foobar')\"]" {
    run docker run --rm run-exec-form ls -1 foobar
    assert_output 'foobar'
}
