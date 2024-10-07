# shellcheck disable=SC2317 # bats test make some code appear unreachable

setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 "--build-arg=BASE_IMAGE=${MICROMAMBA_IMAGE}" \
                 "--platform=${DOCKER_PLATFORM}" \
                 "--tag=${MICROMAMBA_IMAGE}-cmd-exec-form" \
		 "--file=${PROJECT_ROOT}/test/cmd-exec-form.Dockerfile" \
		 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "CMD [\"/opt/conda/bin/python\", \"-c\", \"print('hello')\"]" {
    run docker run --rm "--platform=${DOCKER_PLATFORM}" "${MICROMAMBA_IMAGE}-cmd-exec-form"
    assert_output 'hello'
}

@test "CMD [\"/opt/conda/bin/python\", \"-c\", \"print('hello')\"] with --user" {
    run docker run --rm "--platform=${DOCKER_PLATFORM}" --user=1001:1001 "${MICROMAMBA_IMAGE}-cmd-exec-form"
    assert_output 'hello'
}
