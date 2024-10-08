#!/bin/bash
set -eu -o pipefail

if [[ $# -ne 0 ]]; then
    echo "Usage: $0" >&2
    exit 2
fi

project_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

action="${project_root}/.github/workflows/push_latest.yml"

failed_images=()
while IFS='' read -r image; do
  echo "Testing with base image ${image}..."
  if "${project_root}/test_with_base_image.sh" "${image}"; then
    echo "All tests passed for base image ${image}"
  else
    echo "Tests failed for base image ${image}"
    failed_images+=("${image}")
  fi
done < <(awk '/steps:$/{exit} f {print $2}; /image:$/{f=1}' "${action}")

if [[ ${#failed_images[@]} -gt 0 ]]; then
  echo "The following base images failed the tests:"
  for image in "${failed_images[@]}"; do
    echo "  ${image}"
  done
  exit 1
fi
