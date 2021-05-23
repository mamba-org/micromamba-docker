setup() {
    load 'test_helper/common-setup'
    _common_setup
    docker build -t micromamba:test -f ${PROJECT_ROOT}/Dockerfile "$PROJECT_ROOT"
    docker build -t run-shell-form  -f ${PROJECT_ROOT}/test/run-shell-form.Dockerfile "${PROJECT_ROOT}/test"
}

@test "RUN python -c \"import os; os.system('touch foobar')\"" {
    run docker run --rm run-shell-form ls -1 foobar
    assert_output 'foobar'
}
