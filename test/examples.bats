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
    sed -E "s%^FROM mambaorg/micromamba:[^ ]+%FROM --platform=\$TARGETPLATFORM ${MICROMAMBA_IMAGE}%" "$ORG" > "${ORG}.test"
    docker build --quiet \
                 "--platform=${DOCKER_PLATFORM}" \
                 "--tag=${MICROMAMBA_IMAGE}-${1}" \
                 "--file=${ORG}.test" \
                 "$PROJECT_ROOT/examples/${1}" > /dev/null && \
    rm "${ORG}.test"
}

@test "examples/add_micromamba" {
    test_example add_micromamba
    # shellcheck disable=SC2086
    run docker run $RUN_FLAGS "${MICROMAMBA_IMAGE}-add_micromamba" jq --version
    assert_success
}

@test "examples/apt_install" {
    if [[ $DISTRO_ID =~ alpine ]] || [[ $DISTRO_ID =~ fedora ]]; then
      # shellcheck disable=SC1009
      skip "apt-git install is not supported on this distribution"
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

@test "examples/run_activate" {
    test_example run_activate
}
