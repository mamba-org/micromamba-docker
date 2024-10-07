# shellcheck disable=SC2317 # bats test make some code appear unreachable

_common_setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." >/dev/null 2>&1 && pwd )"

    TAG="$(echo "$BASE_IMAGE" | tr ':/' '-')"

    export MICROMAMBA_IMAGE="micromamba:test-${TAG}"
    DOCKER_PLATFORM="linux/amd64"
    RUN_FLAGS="--rm --platform=${DOCKER_PLATFORM}"
    export RUN_FLAGS

    DISTRO_ID="$(docker run --rm --platform=${DOCKER_PLATFORM} "${BASE_IMAGE}" /bin/sh -c "\
	           ( grep '^ID_LIKE=' /etc/os-release || grep '^ID=' /etc/os-release )" \
                   | tr -d '"' \
		   | cut -d= -f2-)"
    export DISTRO_ID
    docker build --quiet \
		 "--build-arg=BASE_IMAGE=${BASE_IMAGE}" \
		 "--platform=${DOCKER_PLATFORM}" \
     "--tag=${MICROMAMBA_IMAGE}" \
		 "--file=${PROJECT_ROOT}/${DISTRO_ID}.Dockerfile" \
		 "$PROJECT_ROOT" > /dev/null


    # Simulate TTY input for the docker run command
    # https://stackoverflow.com/questions/1401002/
    faketty () {
      local tmp cmd err
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
        SHELL=/bin/sh script -qfc "$cmd" /dev/null
      fi

      # Ensure that the status code was written to the temporary file or
      # fail with status 99
      [ -s "$tmp" ] || return 99

      # Collect the status code from the temporary file
      err=$(cat "$tmp")

      # Remove the temporary file
      rm -f "$tmp"

      # Return the status code
      return "$err"
    }
}
