#!/usr/bin/env bash

set -ef -o pipefail

# if USER is not set and not root
if [[ ! -v USER && $(id -u) -gt 0 ]]; then
  # should get here if 'docker run...' was passed -u with a numeric UID
  export USER="micromamba"
  export HOME="/home/$USER"
fi

eval "$(/bin/micromamba shell hook -s bash)"
micromamba activate "$ENV_NAME"

# allow interactive use in default bash command
/bin/micromamba shell init -p $MAMBA_ROOT_PREFIX -s bash > /dev/null
/bin/micromamba shell completion -s bash > /dev/null
echo "micromamba activate $ENV_NAME" >> ~/.bashrc

exec "$@"
