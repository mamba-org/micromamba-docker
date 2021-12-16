setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 --tag=cli-invocations \
		 --file=${PROJECT_ROOT}/test/cli-invocations.Dockerfile \
		 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

# Simulate TTY input for the docker run command
# https://stackoverflow.com/questions/1401002/
faketty () {
  # Create a temporary file for storing the status code
  tmp=$(mktemp)

  # Ensure it worked or fail with status 99
  [ "$tmp" ] || return 99

  # Produce a script that runs the command provided to faketty as
  # arguments and stores the status code in the temporary file
  cmd="$(printf '%q ' "$@")"'; echo $? > '$tmp

  # Run the script through /bin/sh with fake tty
  if [ "$(uname)" = "Darwin" ]; then
    # MacOS
    script -Fq /dev/null /bin/sh -c "$cmd"
  else
    script -qfc "/bin/sh -c $(printf "%q " "$cmd")" /dev/null
  fi

  # Ensure that the status code was written to the temporary file or
  # fail with status 99
  [ -s $tmp ] || return 99

  # Collect the status code from the temporary file
  err=$(cat $tmp)

  # Remove the temporary file
  rm -f $tmp

  # Return the status code
  return $err
}


# Activation should succeed in the simplest case.
@test "docker run --rm cli-invocations python --version" {
    docker run --rm cli-invocations python --version
}

# Activation should skip in the simplest case when MAMBA_SKIP_ACTIVATE=1.
@test "docker run --rm -e MAMBA_SKIP_ACTIVATE=1 cli-invocations python --version" {
    ! docker run --rm -e MAMBA_SKIP_ACTIVATE=1 cli-invocations python --version

    # Make sure that a similar command actually succeeds
    docker run --rm -e MAMBA_SKIP_ACTIVATE=1 cli-invocations micromamba --version
}

# Activation should succeed in an interactive terminal.
@test "'docker run --rm -it cli-invocations' with 'python --version; exit'" {
    input="python --version; exit"
    echo -e $input | faketty \
        docker run --rm -it cli-invocations
    
    # Make sure that a similar command actually fails
    input="xyz --version; exit"
    ! echo -e $input | faketty \
        docker run --rm -it cli-invocations
}

# Activation should also succeed in an interactive terminal with the entrypoint
# disabled, thanks to activation in .bashrc.
@test "'docker run --rm -it --entrypoint=/bin/bash cli-invocations' with 'python --version; exit'" {
    input="python --version; exit"
    echo -e $input | faketty \
        docker run --rm -it --entrypoint=/bin/bash cli-invocations
    
    # Make sure that a similar command actually fails
    input="xyz --version; exit"
    ! echo -e $input | faketty \
        docker run --rm -it --entrypoint=/bin/bash cli-invocations
}

# ... Now that we isolated activation to .bashrc, disable it via MAMBA_SKIP_ACTIVATE=1.
@test "'docker run --rm -it --entrypoint=/bin/bash -e MAMBA_SKIP_ACTIVATE=1 cli-invocations' with 'python --version; exit'" {
    input="python --version; exit"
    ! echo -e $input | faketty \
        docker run --rm -it --entrypoint=/bin/bash -e MAMBA_SKIP_ACTIVATE=1 cli-invocations
    
    # Make sure that a similar command actually succeeds
    input="micromamba --version; exit"
    echo -e $input | faketty \
        docker run --rm -it --entrypoint=/bin/bash -e MAMBA_SKIP_ACTIVATE=1 cli-invocations
}

# Unlike the interactive terminal above, in a non-interactive terminal, activation skips
# when the entrypoint is overridden because "bash -c" sources .bashrc non-interactively.
@test "docker run --rm --entrypoint='' cli-invocations /bin/bash -c 'python --version'" {
    ! docker run --rm --entrypoint='' cli-invocations /bin/bash -c 'python --version'

    # Make sure that a similar command actually succeeds
    docker run --rm --entrypoint='' cli-invocations /bin/bash -c 'micromamba --version'
}

# ... Therefore, activation succeeds exclusively thanks to the entrypoint.
@test "docker run --rm cli-invocations /bin/bash -c 'python --version'" {
    docker run --rm cli-invocations /bin/bash -c 'python --version'
}

# ... Verify that MAMBA_SKIP_ACTIVATE=1 correctly skips activation from the entrypoint.
@test "docker run --rm -e MAMBA_SKIP_ACTIVATE=1 cli-invocations /bin/bash -c 'python --version'" {
    ! docker run --rm -e MAMBA_SKIP_ACTIVATE=1 cli-invocations /bin/bash -c 'python --version'

    # Make sure that a similar command actually succeeds
    docker run --rm -e MAMBA_SKIP_ACTIVATE=1 cli-invocations /bin/bash -c 'micromamba --version'
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
        docker run --rm -it --user=root -e MAMBA_SKIP_ACTIVATE=1 cli-invocations
}
