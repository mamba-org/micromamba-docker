setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 "--build-arg=BASE_IMAGE=${MICROMAMBA_IMAGE}" \
                 "--tag=${MICROMAMBA_IMAGE}-conda-mamba-activate" \
		 "--file=${PROJECT_ROOT}/test/conda-mamba-activate.Dockerfile" \
		 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "'docker run --rm -it \"${MICROMAMBA_IMAGE}-conda-mamba-activate\"' with 'conda activate base && mamba activate base; exit'" {
    input="conda activate base && mamba activate base; exit"
    echo -e "$input" | faketty \
        docker run --rm -it "${MICROMAMBA_IMAGE}-conda-mamba-activate"
}
