#!/usr/bin/env bash

set -ef -o pipefail

# Activate the environment if $MAMBA_DOCKERFILE_ACTIVATE=1
if [[ "${MAMBA_DOCKERFILE_ACTIVATE}" == "1" ]]; then
  eval "$(/bin/micromamba shell hook --shell=bash)"
  # For robustness, try all possible activate commands.
  conda activate "${ENV_NAME}" 2>/dev/null \
  || mamba activate "${ENV_NAME}" 2>/dev/null \
  || micromamba activate "${ENV_NAME}"
fi

exec bash -o pipefail -c "$@"
