setup_file() {
    load 'test_helper/common-setup'
    _common_setup
}

setup() {
    load 'test_helper/common-setup'
    _common_setup
}

@test "build examples/cmdline_spec/Dockerfile" {
    docker build --quiet \
                 --tag=micromamba:cmdline_spec \
		 --file=${PROJECT_ROOT}/examples/cmdline_spec/Dockerfile \
		 "$PROJECT_ROOT/examples/cmdline_spec" > /dev/null
}

@test "build examples/multi_env/Dockerfile" {
    docker build --quiet \
                 --tag=micromamba:multi_env \
		 --file=${PROJECT_ROOT}/examples/multi_env/Dockerfile \
		 "$PROJECT_ROOT/examples/multi_env" > /dev/null
}

@test "build examples/yaml_spec/Dockerfile" {
    docker build --quiet \
                 --tag=micromamba:yaml_spec \
		 --file=${PROJECT_ROOT}/examples/yaml_spec/Dockerfile \
		 "$PROJECT_ROOT/examples/yaml_spec" > /dev/null
}
