#!/usr/bin/env bash

set -euf -o pipefail

# if USER is not set and not root
if [[ ! -v USER && $(id -u) -gt 0 ]]; then
  # should get here if 'docker run...' was passed -u with a numeric UID
  export USER="micromamba"
  export HOME="/home/$USER"
fi
if [[ "$ENV_NAME" !=  "bash" ]]; then
  export PATH="${MAMBA_ROOT_PREFIX}/envs/${ENV_NAME}/bin:$PATH"
fi
export BASH_ENV="${HOME}/.bashrc"
mkdir -p "$HOME"
/bin/micromamba shell init -s bash -p "$MAMBA_ROOT_PREFIX" > /dev/null
echo "micromamba activate $ENV_NAME" >> "$BASH_ENV"

exec "$@"
