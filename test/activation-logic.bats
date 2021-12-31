setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 --tag=micromamba:test-cli-invocations \
		 --file=${PROJECT_ROOT}/test/cli-invocations.Dockerfile \
		 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

# Activation should succeed in the simplest case.
@test "docker run --rm micromamba:test-cli-invocations python --version" {
    docker run --rm micromamba:test-cli-invocations python --version
}

# Activation should skip in the simplest case when MAMBA_SKIP_ACTIVATE=1.
@test "docker run --rm -e MAMBA_SKIP_ACTIVATE=1 micromamba:test-cli-invocations python --version" {
    ! docker run --rm -e MAMBA_SKIP_ACTIVATE=1 micromamba:test-cli-invocations python --version

    # Make sure that a similar command actually succeeds
    docker run --rm -e MAMBA_SKIP_ACTIVATE=1 micromamba:test-cli-invocations micromamba --version
}

# Activation should succeed in an interactive terminal.
@test "'docker run --rm -it micromamba:test-cli-invocations' with 'python --version; exit'" {
    input="python --version; exit"
    echo -e $input | faketty \
        docker run --rm -it micromamba:test-cli-invocations
    
    # Make sure that a similar command actually fails
    input="xyz --version; exit"
    ! echo -e $input | faketty \
        docker run --rm -it micromamba:test-cli-invocations
}

# Activation should also succeed in an interactive terminal with the entrypoint
# disabled, thanks to activation in .bashrc.
@test "'docker run --rm -it --entrypoint=/bin/bash micromamba:test-cli-invocations' with 'python --version; exit'" {
    input="python --version; exit"
    echo -e $input | faketty \
        docker run --rm -it --entrypoint=/bin/bash micromamba:test-cli-invocations
    
    # Make sure that a similar command actually fails
    input="xyz --version; exit"
    ! echo -e $input | faketty \
        docker run --rm -it --entrypoint=/bin/bash micromamba:test-cli-invocations
}

# ... Now that we isolated activation to .bashrc, disable it via MAMBA_SKIP_ACTIVATE=1.
@test "'docker run --rm -it --entrypoint=/bin/bash -e MAMBA_SKIP_ACTIVATE=1 micromamba:test-cli-invocations' with 'python --version; exit'" {
    input="python --version; exit"
    ! echo -e $input | faketty \
        docker run --rm -it --entrypoint=/bin/bash -e MAMBA_SKIP_ACTIVATE=1 micromamba:test-cli-invocations
    
    # Make sure that a similar command actually succeeds
    input="micromamba --version; exit"
    echo -e $input | faketty \
        docker run --rm -it --entrypoint=/bin/bash -e MAMBA_SKIP_ACTIVATE=1 micromamba:test-cli-invocations
}

# Unlike the interactive terminal above, in a non-interactive terminal, activation skips
# when the entrypoint is overridden because "bash -c" sources .bashrc non-interactively.
@test "docker run --rm --entrypoint='' micromamba:test-cli-invocations /bin/bash -c 'python --version'" {
    ! docker run --rm --entrypoint='' micromamba:test-cli-invocations /bin/bash -c 'python --version'

    # Make sure that a similar command actually succeeds
    docker run --rm --entrypoint='' micromamba:test-cli-invocations /bin/bash -c 'micromamba --version'
}

# ... Therefore, activation succeeds exclusively thanks to the entrypoint.
@test "docker run --rm micromamba:test-cli-invocations /bin/bash -c 'python --version'" {
    docker run --rm micromamba:test-cli-invocations /bin/bash -c 'python --version'
}

# ... Verify that MAMBA_SKIP_ACTIVATE=1 correctly skips activation from the entrypoint.
@test "docker run --rm -e MAMBA_SKIP_ACTIVATE=1 micromamba:test-cli-invocations /bin/bash -c 'python --version'" {
    ! docker run --rm -e MAMBA_SKIP_ACTIVATE=1 micromamba:test-cli-invocations /bin/bash -c 'python --version'

    # Make sure that a similar command actually succeeds
    docker run --rm -e MAMBA_SKIP_ACTIVATE=1 micromamba:test-cli-invocations /bin/bash -c 'micromamba --version'
}

# Verify that activation works in an initially deactivated interactive terminal when
# switching users.
#   Steps: disable automatic activation, start as root, reenable activation, switch to
#          user, verify that the environment is activated.
@test "Verify activation when switching users." {
    input="
        ! which python  \n
        MAMBA_SKIP_ACTIVATE=0  \n
        su micromamba  \n
            python --version  \n
            exit  \n
        exit  \n
    "
    echo -e $input | faketty \
        docker run --rm -it --user=root -e MAMBA_SKIP_ACTIVATE=1 micromamba:test-cli-invocations
}
