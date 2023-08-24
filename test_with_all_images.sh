#!/bin/bash
set -eu -o pipefail

if [[ $# -ne 0 ]]; then
    echo "Usage: $0" >&2
    exit 2
fi

project_root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

action="${project_root}/.github/workflows/push_latest.yml"

while IFS='' read -r image; do
  "${project_root}/test_with_base_image.sh" "$image"
done < <(awk '/steps:$/{exit} f {print $2}; /image:$/{f=1}' "${action}")
