#!/usr/bin/env bash

_common_setup() {
    load 'test_helper/bats-support/load'
    load 'test_helper/bats-assert/load'

    PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." >/dev/null 2>&1 && pwd )"
    PATH="$PROJECT_ROOT/src:$PATH"
}
