# shellcheck disable=SC2317 # bats test make some code appear unreachable

setup_file() {
    load 'test_helper/common-setup'
    _common_setup
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

test_example() {
    ORG="${PROJECT_ROOT}/examples/${1}/Dockerfile"
    sed -E "s%^FROM mambaorg/micromamba:[^ ]+%FROM ${MICROMAMBA_IMAGE}%" "$ORG" > "${ORG}.test"
    docker build --quiet \
                 "--tag=${MICROMAMBA_IMAGE}-${1}" \
		 "--file=${ORG}.test" \
		 "$PROJECT_ROOT/examples/${1}" > /dev/null && \
    rm "${ORG}.test"
}

@test "examples/add_micromamba" {
    test_example add_micromamba
}

@test "example/cmdline_spec" {
    test_example cmdline_spec
}

@test "example/modify_username" {
    test_example modify_username
}

@test "example/multi_env" {
    test_example multi_env
}

@test "example/yaml_spec" {
    test_example yaml_spec
}
