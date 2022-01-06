setup_file() {
    load 'test_helper/common-setup'
    _common_setup
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "build examples/cmdline_spec/Dockerfile" {
    ORG="${PROJECT_ROOT}/examples/cmdline_spec/Dockerfile"
    sed "s%^FROM mambaorg/micromamba:.*$%FROM micromamba:test%" "$ORG" > "${ORG}.test"
    docker build --quiet \
                 --tag=micromamba:test-cmdline_spec \
		 --file=${ORG}.test \
		 "$PROJECT_ROOT/examples/cmdline_spec" > /dev/null && \
    rm ${ORG}.test
}

@test "build examples/multi_env/Dockerfile" {
    ORG="${PROJECT_ROOT}/examples/multi_env/Dockerfile"
    sed "s%^FROM mambaorg/micromamba:.*$%FROM micromamba:test%" "$ORG" > "${ORG}.test"
    docker build --quiet \
                 --tag=micromamba:test-multi_env \
		 --file=${ORG}.test \
		 "$PROJECT_ROOT/examples/multi_env" > /dev/null && \
    rm ${ORG}.test
}

@test "build examples/yaml_spec/Dockerfile" {
    ORG="${PROJECT_ROOT}/examples/yaml_spec/Dockerfile"
    sed "s%^FROM mambaorg/micromamba:.*$%FROM micromamba:test%" "$ORG" > "${ORG}.test"
    docker build --quiet \
                 --tag=micromamba:test-yaml_spec \
		 --file=${ORG}.test \
		 "$PROJECT_ROOT/examples/yaml_spec" > /dev/null && \
    rm ${ORG}.test
}
