#!/usr/bin/env bash

set -ef -o pipefail

# if USER is not set and not root
if [[ ! -v USER && $(id -u) -gt 0 ]]; then
  # should get here if 'docker run...' was passed -u with a numeric UID
  export USER="$MAMBA_USER"
  export HOME="/home/$USER"
fi

source _activate_current_env.sh

exec "$@"
