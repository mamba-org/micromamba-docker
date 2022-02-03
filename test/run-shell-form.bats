setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 --build-arg "BASE_IMAGE=${MICROMAMBA_IMAGE}" \
                 "--tag=${MICROMAMBA_IMAGE}-run-shell-form" \
		 "--file=${PROJECT_ROOT}/test/run-shell-form.Dockerfile" \
		 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "RUN python -c \"import os; os.system('touch foobar')\"" {
    run docker run --rm "${MICROMAMBA_IMAGE}-run-shell-form" ls -1 foobar
    assert_output 'foobar'
}
