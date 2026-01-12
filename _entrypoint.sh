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

if [[ $(id -u) -gt 0 ]]; then
  if [[ ! -v USER ]]; then
    export USER="$MAMBA_USER"
  fi
  # If a user passes HOME="/", it will still get clobbered.
  # I don't have a good way to work around that.
  if [[ $HOME == "/" ]]; then
    export HOME="/home/$USER"
  fi
fi

source _activate_current_env.sh

exec "$@"
