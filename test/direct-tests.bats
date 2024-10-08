# shellcheck disable=SC2317 # bats test make some code appear unreachable

setup_file() {
    load 'test_helper/common-setup'
    _common_setup
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "docker run ${MICROMAMBA_IMAGE} /bin/bash -i -c 'declare -F micromamba'" {
    # shellcheck disable=SC2086
    docker run $RUN_FLAGS "${MICROMAMBA_IMAGE}" /bin/bash -i -c 'declare -F micromamba'
}

@test "docker run ${MICROMAMBA_IMAGE} /bin/bash -i -c 'echo \$PS1 | cut -f1 -d\" \"'" {
  # shellcheck disable=SC2086
  run docker run $RUN_FLAGS "${MICROMAMBA_IMAGE}" /bin/bash  -i -c 'echo $PS1 | cut -f1 -d" "'
  assert_line '(base)'
}
