#!/usr/bin/env bash

set -ef -o pipefail

# If the file /etc/arg_mamba_user exists and its contents don't match $MAMBA_USER...
if [[ -f /etc/arg_mamba_user && "${MAMBA_USER}" != "$(cat "/etc/arg_mamba_user")" ]]; then
    echo "ERROR: This micromamba-docker image was built with" \
    "'ARG MAMBA_USER=$(cat "/etc/arg_mamba_user")', but the corresponding" \
    "environment variable has been modified to 'MAMBA_USER=${MAMBA_USER}'." \
    "For instructions on how to properly change the username, please refer" \
    "to the documentation at <https://github.com/mamba-org/micromamba-docker>." >&2
    exit 1
fi

# if USER is not set and not root
if [[ ! -v USER && $(id -u) -gt 0 ]]; then
  # should get here if 'docker run...' was passed -u with a numeric UID
  export USER="$MAMBA_USER"
  export HOME="/home/$USER"
fi

source _activate_current_env.sh

exec "$@"
