# This script should never be called directly, only sourced:

#     source _activate_current_env.sh

if [[ "${MAMBA_SKIP_ACTIVATE}" == "1" ]]; then
  return
fi

# Initialize the current shell
eval "$(MAMBA_ROOT_PREFIX=/_invalid "${MAMBA_EXE}" shell hook --shell=bash)"
# Note: adding "MAMBA_ROOT_PREFIX=/_invalid" is an ugly temporary workaround
# for <https://github.com/mamba-org/mamba/issues/1322>.

# For robustness, try all possible activate commands.
conda activate "${ENV_NAME}" 2>/dev/null \
  || mamba activate "${ENV_NAME}" 2>/dev/null \
  || micromamba activate "${ENV_NAME}"
