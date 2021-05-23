setup() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 --tag=micromamba:test \
		 --file=${PROJECT_ROOT}/Dockerfile \
		 "$PROJECT_ROOT" > /dev/null
    docker build --quiet \
                 --tag=cmd-shell-form \
		 --file=${PROJECT_ROOT}/test/cmd-shell-form.Dockerfile \
		 "${PROJECT_ROOT}/test" > /dev/null
}

@test "CMD python -c \"print('hello')\"" {
    run docker run --rm cmd-shell-form
    assert_output 'hello'
}

@test "CMD python -c \"print('hello')\" with --user" {
    run docker run --rm --user=1001:1001 cmd-shell-form
    assert_output 'hello'
}
