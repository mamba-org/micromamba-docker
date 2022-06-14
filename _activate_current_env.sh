# This script should never be called directly, only sourced:

#     source _activate_current_env.sh

if [[ "${MAMBA_SKIP_ACTIVATE}" == "1" ]]; then
  return
fi

# Initialize the current shell
eval "$("${MAMBA_EXE}" shell hook --shell=bash)"

# Try to initialize Conda in case it is installed.
__conda_setup="$('conda' 'shell.bash' 'hook' 2> /dev/null)" || true
if [ ! -z "${__conda_setup}" ]; then
    eval "$__conda_setup"
else
    if [ -f "${CONDA_PREFIX}/etc/profile.d/conda.sh" ]; then
        . "${CONDA_PREFIX}/etc/profile.d/conda.sh"
    fi
fi
unset __conda_setup

# Initialize Mamba in case it is on the path.
if [ -f "${CONDA_PREFIX}/etc/profile.d/mamba.sh" ]; then
    . "${CONDA_PREFIX}/etc/profile.d/mamba.sh"
fi

# For robustness, try all possible activate commands.
conda activate "${ENV_NAME}" 2>/dev/null \
  || mamba activate "${ENV_NAME}" 2>/dev/null \
  || micromamba activate "${ENV_NAME}"
