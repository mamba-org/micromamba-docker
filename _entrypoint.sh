#!/bin/bash

set -ef -o pipefail

# if USER is not set and not root
if [[ ! -v USER && $(id -u) -gt 0 ]]; then
  # should get here if 'docker run...' was passed -u with a numeric UID
  export USER="micromamba"
  export HOME="/home/$USER"
fi

eval "$(/bin/micromamba shell hook -s bash)"
micromamba activate "$ENV_NAME"
exec "$@"
