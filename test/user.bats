setup_file() {
    load 'test_helper/common-setup'
    _common_setup

    if [ -z "${MICROMAMBA_VERSION}" ]; then
      export MICROMAMBA_VERSION="$(./check_version.py 2> /dev/null | cut -f1 -d,)"
    fi

    # only used for building the micromamba image, not derived images
    MICROMAMBA_FLAGS="--build-arg VERSION=${MICROMAMBA_VERSION}"

    docker build $MICROMAMBA_FLAGS \
                 --quiet \
                 --tag=micromamba:test \
		 --file=${PROJECT_ROOT}/Dockerfile \
		 "$PROJECT_ROOT" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "docker run --rm  micromamba:test whoami" {
    run docker run --rm  micromamba:test whoami
    assert_output 'micromamba'
}

@test "docker run --rm  --user=1001:1001 micromamba:test whoami" {
    run docker run --rm  --user=1001:1001 micromamba:test whoami
    assert_output 'whoami: cannot find name for user ID 1001'
}

@test "docker run --rm  --user=root micromamba:test whoami" {
    run docker run --rm  --user=root micromamba:test whoami
    assert_output 'root'
}

@test "docker run --rm  --user=0:0micromamba:test whoami" {
    run docker run --rm  --user=0:0 micromamba:test whoami
    assert_output 'root'
}

@test "docker run --rm  micromamba:test /bin/bash -c 'realpath ~'" {
    run docker run --rm  micromamba:test /bin/bash -c 'realpath ~'
    assert_output '/home/micromamba'
}

@test "docker run --rm  --user=1001:1001 micromamba:test /bin/bash -c 'realpath ~'" {
    run docker run --rm  --user=1001:1001 micromamba:test /bin/bash -c 'realpath ~'
    assert_output '/home/micromamba'
}

@test "docker run --rm  --user=root micromamba:test /bin/bash -c 'realpath ~'" {
    run docker run --rm  --user=root micromamba:test /bin/bash -c 'realpath ~'
    assert_output '/root'
}
