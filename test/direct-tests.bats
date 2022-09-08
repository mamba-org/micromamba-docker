stup_file() {
    load 'test_helper/common-setup'
    _common_setup
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "docker run --rm ${MICROMAMBA_IMAGE} /bin/bash -i -c 'declare -F micromamba'" {
    docker run --rm "${MICROMAMBA_IMAGE}" /bin/bash -i -c 'declare -F micromamba'
}

@test "docker run --rm ${MICROMAMBA_IMAGE} /bin/bash -i -c 'echo \$PS1 | cut -f1 -d\" \"'" {
  run docker run --rm "${MICROMAMBA_IMAGE}" /bin/bash  -i -c 'echo $PS1 | cut -f1 -d" "'
  assert_line '(base)'
}
