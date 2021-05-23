setup() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 --tag=micromamba:test \
		 --file=${PROJECT_ROOT}/Dockerfile \
		 "$PROJECT_ROOT" > /dev/null
    docker build --quiet \
                 --tag=cmd-exec-form \
		 --file=${PROJECT_ROOT}/test/cmd-exec-form.Dockerfile \
		 "${PROJECT_ROOT}/test" > /dev/null
}

@test "CMD [\"/opt/conda/bin/python\", \"-c\", \"print('hello')\"]" {
    run docker run --rm cmd-exec-form
    assert_output 'hello'
}

@test "CMD [\"/opt/conda/bin/python\", \"-c\", \"print('hello')\"] with --user" {
    run docker run --rm --user=1001:1001 cmd-exec-form
    assert_output 'hello'
}
