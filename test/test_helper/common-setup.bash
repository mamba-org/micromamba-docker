#!/usr/bin/env bash

_get_micromamba_version() {
    if [ -z "${MICROMAMBA_VERSION+x}" ]; then
      VENV_DIR="${PROJECT_ROOT}/.venv"
      python3 -m venv --clear "${VENV_DIR}"
      source "${VENV_DIR}/bin/activate"
      pip install --quiet --disable-pip-version-check -r "${PROJECT_ROOT}/requirements.txt"
      MICROMAMBA_VERSION="$("${PROJECT_ROOT}/check_version.py" 2> /dev/null | cut -f1 -d,)"
      export MICROMAMBA_VERSION
    fi
}

_common_setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    TEST_NAME="$1"
    PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." >/dev/null 2>&1 && pwd )"
    
    _get_micromamba_version
    # only used for building the micromamba image, not derived images
    MICROMAMBA_FLAGS="--build-arg VERSION=${MICROMAMBA_VERSION}"

    PATH="$PROJECT_ROOT/src:$PATH"
    while read -r IMAGE_INFO; do
        IFS=';' read -ra IMAGE_ARRAY <<< "$IMAGE_INFO"
        BASE_IMAGE="${IMAGE_ARRAY[0]}"
        DEBIAN_NAME="${IMAGE_ARRAY[1]}"
	echo "TEST_NAME=$TEST_NAME BASE_IMAGE=$BASE_IMAGE, DEBIAN_NAME=$DEBIAN_NAME"
        docker build --quiet \
                     --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
                     "--tag=micromamba:test-${DEBIAN_NAME}" \
                     "--file=${PROJECT_ROOT}/Dockerfile" \
                     "$PROJECT_ROOT" > /dev/null
        docker build --quiet \
                     --build-arg "BASE_IMAGE=micromamba:test-${DEBIAN_NAME}" \
                     "--tag=${TEST_NAME}" \
		     "--file=${PROJECT_ROOT}/test/${TEST_NAME}.Dockerfile" \
		     "${PROJECT_ROOT}/test" > /dev/null
    done < "${PROJECT_ROOT}/tags.tsv"

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
        SHELL=/bin/sh script -qfc "$cmd" /dev/null
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
}
