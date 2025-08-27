# shellcheck disable=SC2317 # bats test make some code appear unreachable

setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    build_image cli-invocations.Dockerfile
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

# Activation should succeed in the simplest case.
@test "docker run ${MICROMAMBA_IMAGE}-cli-invocations python --version" {
    # shellcheck disable=SC2086
    docker run $RUN_FLAGS "${MICROMAMBA_IMAGE}-cli-invocations" python --version
}

# Activation should skip in the simplest case when MAMBA_SKIP_ACTIVATE=1.
@test "docker run -e MAMBA_SKIP_ACTIVATE=1 ${MICROMAMBA_IMAGE}-cli-invocations python --version" {
    # shellcheck disable=SC2329
    f() {
        # shellcheck disable=SC2086
        docker run $RUN_FLAGS -e MAMBA_SKIP_ACTIVATE=1 "${MICROMAMBA_IMAGE}-cli-invocations" "$@"
    }
    run ! f python --version
    # Make sure that a similar command actually succeeds
    run f micromamba --version
}

# Activation should succeed in an interactive terminal.
@test "'docker run -it ${MICROMAMBA_IMAGE}-cli-invocations' with 'python --version; exit'" {
    # shellcheck disable=SC2329
    f() {
        # shellcheck disable=SC2086
        echo -e "$1" | faketty \
            docker run $RUN_FLAGS -it "${MICROMAMBA_IMAGE}-cli-invocations"
    }
    run f 'python --version; exit'
    # Make sure that a similar command actually fails
    run ! f 'xyz --version; exit'
}

# Activation should also succeed in an interactive terminal with the entrypoint
# disabled, thanks to activation in .bashrc.
@test "'docker run -it --entrypoint=/bin/bash ${MICROMAMBA_IMAGE}-cli-invocations' with 'python --version; exit'" {
    # shellcheck disable=SC2329
    f() {
        # shellcheck disable=SC2086
        echo -e "$1" | faketty \
            docker run $RUN_FLAGS -it --entrypoint=/bin/bash "${MICROMAMBA_IMAGE}-cli-invocations"
    }
    run f 'python --version; exit'
    # Make sure that a similar command actually fails
    run ! f 'xyz --version; exit'
}

# ... Now that we isolated activation to .bashrc, disable it via MAMBA_SKIP_ACTIVATE=1.
@test "'docker run -it --entrypoint=/bin/bash -e MAMBA_SKIP_ACTIVATE=1 ${MICROMAMBA_IMAGE}-cli-invocations' with 'python --version; exit'" {
    # shellcheck disable=SC2329
    f() {
        # shellcheck disable=SC2086
        echo -e "$1" | faketty \
            docker run $RUN_FLAGS -it --entrypoint=/bin/bash -e MAMBA_SKIP_ACTIVATE=1 "${MICROMAMBA_IMAGE}-cli-invocations"
    }
    run ! f 'python --version; exit'
    # Make sure that a similar command actually succeeds
    run f 'micromamba --version; exit'
    # check that micromamba shell initializtion occurs when env activation is skipped
    run f 'micromamba activate base; exit'
}

# Unlike the interactive terminal above, in a non-interactive terminal, activation skips
# when the entrypoint is overridden because "bash -c" sources .bashrc non-interactively.
@test "docker run --entrypoint='' ${MICROMAMBA_IMAGE}-cli-invocations /bin/bash -c 'python --version'" {
    # shellcheck disable=SC2329
    f() {
        # shellcheck disable=SC2086
        docker run $RUN_FLAGS --entrypoint='' "${MICROMAMBA_IMAGE}-cli-invocations" /bin/bash -c "$1"
    }
    run ! f 'python --version'
    # Make sure that a similar command actually succeeds
    run f 'micromamba --version'
}

# ... Therefore, activation succeeds exclusively thanks to the entrypoint.
@test "docker run ${MICROMAMBA_IMAGE}-cli-invocations /bin/bash -c 'python --version'" {
    # shellcheck disable=SC2086
    docker run $RUN_FLAGS "${MICROMAMBA_IMAGE}-cli-invocations" /bin/bash -c 'python --version'
}

# ... Verify that MAMBA_SKIP_ACTIVATE=1 correctly skips activation from the entrypoint.
@test "docker run -e MAMBA_SKIP_ACTIVATE=1 ${MICROMAMBA_IMAGE}-cli-invocations /bin/bash -c 'python --version'" {
    # shellcheck disable=SC2329
    f() {
        # shellcheck disable=SC2086
        docker run $RUN_FLAGS -e MAMBA_SKIP_ACTIVATE=1 "${MICROMAMBA_IMAGE}-cli-invocations" /bin/bash -c "$1"
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
        # shellcheck disable=SC2086
        echo -e "$1" | faketty \
            docker run $RUN_FLAGS -it --user=root -e MAMBA_SKIP_ACTIVATE=1 "${MICROMAMBA_IMAGE}-cli-invocations"
    }
    run f "$input"
}
