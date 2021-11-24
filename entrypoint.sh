#!/usr/bin/env bash

set -ef -o pipefail

# if USER is not set and not root
if [[ ! -v USER && $(id -u) -gt 0 ]]; then
  # should get here if 'docker run...' was passed -u with a numeric UID
  export USER="micromamba"
  export HOME="/home/$USER"
fi

/bin/micromamba shell init -p $MAMBA_ROOT_PREFIX > /dev/null
/bin/micromamba shell completion > /dev/null
echo "micromamba activate $ENV_NAME" >> ~/.bashrc
source ~/.bashrc
exec "$@"
