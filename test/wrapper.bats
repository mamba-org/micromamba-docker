#!/usr/bin/env bats

cd "$BATS_TEST_DIRNAME"

@test "wrapper" {
  final_status=0
  PROJECT_ROOT="$( cd "$( dirname "$BATS_TEST_FILENAME" )/.." >/dev/null 2>&1 && pwd )"
  while read -r IMAGE_INFO; do
    IFS=';' read -ra IMAGE_ARRAY <<< "$IMAGE_INFO"
    BASE_IMAGE="${IMAGE_ARRAY[0]}"
    DEBIAN_NAME="${IMAGE_ARRAY[1]}"
    #for TEST_NAME in $(find . -name '*.bats' | grep -v wrapper.bats); do
    for TEST_NAME in $(ls -1 *.bats | grep -v wrapper.bats); do
      BASE_IMAGE="$BASE_IMAGE" DEBIAN_NAME="$DEBIAN_NAME" run bats -t "$TEST_NAME"
      echo "# $output" >&3
      echo "#" >&3
      final_status=$(($final_status + $status))
    done
  done < "${PROJECT_ROOT}/tags.tsv"
  [ "$final_status" -eq 0 ]
}
