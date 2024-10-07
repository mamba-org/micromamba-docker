# shellcheck disable=SC2317 # bats test make some code appear unreachable

setup_file() {
    load 'test_helper/common-setup'
    _common_setup
    docker build --quiet \
                 "--build-arg=BASE_IMAGE=${MICROMAMBA_IMAGE}" \
                 "--platform=${DOCKER_PLATFORM}" \
                 "--tag=${MICROMAMBA_IMAGE}-conda-mamba-activate" \
                 "--file=${PROJECT_ROOT}/test/conda-mamba-activate.Dockerfile" \
                 "${PROJECT_ROOT}/test" > /dev/null
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "'docker run -it \"${MICROMAMBA_IMAGE}-conda-mamba-activate\"' with 'conda activate base && mamba activate base; exit'" {
    input="conda activate base && mamba activate base; exit"
    echo -e "$input" | faketty \
        docker run --rm "--platform=${DOCKER_PLATFORM}" -it "${MICROMAMBA_IMAGE}-conda-mamba-activate"
}
