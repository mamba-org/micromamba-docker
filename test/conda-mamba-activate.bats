# shellcheck disable=SC2317 # bats test make some code appear unreachable

setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    build_image conda-mamba-activate.Dockerfile
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "'docker run -it \"${MICROMAMBA_IMAGE}-conda-mamba-activate\"' with 'conda activate base && mamba activate base; exit'" {
    input="conda activate base && mamba activate base; exit"
    # shellcheck disable=SC2086
    echo -e "$input" | faketty \
        docker run $RUN_FLAGS -it "${MICROMAMBA_IMAGE}-conda-mamba-activate"
}
