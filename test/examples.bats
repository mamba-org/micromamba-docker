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

@test "examples/apt_install" {
    if [[ $BASE_IMAGE =~ "alpine" ]]; then
      # shellcheck disable=SC1009
      skip "apt-git install is not supported on Alpine"
    fi
    test_example apt_install
}

@test "examples/cmdline_spec" {
    test_example cmdline_spec
}

@test "examples/generate_lock" {
    ORG="${PROJECT_ROOT}/examples/generate_lock/generate_lock.sh"
    sed -E "s%mambaorg/micromamba:[^ ]+%${MICROMAMBA_IMAGE}%" "$ORG" > "${ORG}.test"
    # shellcheck source=/dev/null
    { cd "$(dirname "${ORG}")" && . "${ORG}.test"; }
    rm "${ORG}.test"
}

@test "examples/install_lock" {
    test_example install_lock
}

@test "examples/modify_username" {
    test_example modify_username
}

@test "examples/multi_env" {
    test_example multi_env
}

@test "examples/new_lock" {
    test_example new_lock
}

@test "examples/yaml_spec" {
    test_example yaml_spec
}
