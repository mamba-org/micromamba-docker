setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 "--build-arg=BASE_IMAGE=${MICROMAMBA_IMAGE}" \
                 "--tag=${MICROMAMBA_IMAGE}-cli-invocations" \
		 "--file=${PROJECT_ROOT}/test/cli-invocations.Dockerfile" \
		 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

# Activation should succeed in the simplest case.
@test "docker run --rm ${MICROMAMBA_IMAGE}-cli-invocations python --version" {
    docker run --rm "${MICROMAMBA_IMAGE}-cli-invocations" python --version
}

# Activation should skip in the simplest case when MAMBA_SKIP_ACTIVATE=1.
@test "docker run --rm -e MAMBA_SKIP_ACTIVATE=1 ${MICROMAMBA_IMAGE}-cli-invocations python --version" {
    f() {
        docker run --rm -e MAMBA_SKIP_ACTIVATE=1 "${MICROMAMBA_IMAGE}-cli-invocations" "$@"
    }
    run ! f python --version
    # Make sure that a similar command actually succeeds
    run f micromamba --version
}

# Activation should succeed in an interactive terminal.
@test "'docker run --rm -it ${MICROMAMBA_IMAGE}-cli-invocations' with 'python --version; exit'" {
    f() {
        echo -e "$1" | faketty \
            docker run --rm -it "${MICROMAMBA_IMAGE}-cli-invocations"
    }
    run f 'python --version; exit'
    # Make sure that a similar command actually fails
    run ! f 'xyz --version; exit'
}

# Activation should also succeed in an interactive terminal with the entrypoint
# disabled, thanks to activation in .bashrc.
@test "'docker run --rm -it --entrypoint=/bin/bash ${MICROMAMBA_IMAGE}-cli-invocations' with 'python --version; exit'" {
    f() {
        echo -e "$1" | faketty \
            docker run --rm -it --entrypoint=/bin/bash "${MICROMAMBA_IMAGE}-cli-invocations"
    }
    run f 'python --version; exit'
    # Make sure that a similar command actually fails
    run ! f 'xyz --version; exit'
}

# ... Now that we isolated activation to .bashrc, disable it via MAMBA_SKIP_ACTIVATE=1.
@test "'docker run --rm -it --entrypoint=/bin/bash -e MAMBA_SKIP_ACTIVATE=1 ${MICROMAMBA_IMAGE}-cli-invocations' with 'python --version; exit'" {
    f() {
        echo -e "$1" | faketty \
            docker run --rm -it --entrypoint=/bin/bash -e MAMBA_SKIP_ACTIVATE=1 "${MICROMAMBA_IMAGE}-cli-invocations"
    }
    run ! f 'python --version; exit'
    # Make sure that a similar command actually succeeds
    run f 'micromamba --version; exit'
    # check that micromamba shell initializtion occurs when env activation is skipped
    run f 'micromamba activate base; exit'
}

# Unlike the interactive terminal above, in a non-interactive terminal, activation skips
# when the entrypoint is overridden because "bash -c" sources .bashrc non-interactively.
@test "docker run --rm --entrypoint='' ${MICROMAMBA_IMAGE}-cli-invocations /bin/bash -c 'python --version'" {
    f() {
        docker run --rm --entrypoint='' "${MICROMAMBA_IMAGE}-cli-invocations" /bin/bash -c "$1"
    }
    run ! f 'python --version'
    # Make sure that a similar command actually succeeds
    run f 'micromamba --version'
}

# ... Therefore, activation succeeds exclusively thanks to the entrypoint.
@test "docker run --rm ${MICROMAMBA_IMAGE}-cli-invocations /bin/bash -c 'python --version'" {
    docker run --rm "${MICROMAMBA_IMAGE}-cli-invocations" /bin/bash -c 'python --version'
}

# ... Verify that MAMBA_SKIP_ACTIVATE=1 correctly skips activation from the entrypoint.
@test "docker run --rm -e MAMBA_SKIP_ACTIVATE=1 ${MICROMAMBA_IMAGE}-cli-invocations /bin/bash -c 'python --version'" {
    f() {
        docker run --rm -e MAMBA_SKIP_ACTIVATE=1 "${MICROMAMBA_IMAGE}-cli-invocations" /bin/bash -c "$1"
    }
    run ! f 'python --version'
    # Make sure that a similar command actually succeeds
    run f 'micromamba --version'
}

# Verify that activation works in an initially deactivated interactive terminal when
# switching users.
#   Steps: disable automatic activation, start as root, reenable activation, switch to
#          user, verify that the environment is activated.
@test "Verify activation when switching users." {
    # shellcheck disable=SC2016
    input='
        ! which python  \n
        MAMBA_SKIP_ACTIVATE=0  \n
        su "$MAMBA_USER"  \n
            python --version  \n
            exit  \n
        exit  \n
    '
    f () {
        echo -e "$1" | faketty \
            docker run --rm -it --user=root -e MAMBA_SKIP_ACTIVATE=1 "${MICROMAMBA_IMAGE}-cli-invocations"
    }
    run f "$input"
}
