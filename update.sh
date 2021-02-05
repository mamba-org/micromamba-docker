#!/bin/bash

set -euf -o pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 version"
  exit 1
fi

VERSION="$1"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

sed -i "s/^ARG VERSION=.*$/ARG VERSION=${VERSION}/" Dockerfile

for f in $(find "${SCRIPT_DIR}/examples" -name Dockerfile); do
  sed -i  "s%^FROM mambaorg/micromamba:.*$%FROM mambaorg/micromamba:${VERSION}%" "$f"
done

sed -i "s%mambaorg/micromamba:.*$%mambaorg/micromamba:${VERSION}%" "${SCRIPT_DIR}/README.md"

podman build -t "micromamba:${VERSION}" .

git add README.md $(find . -name Dockerfile)
git commit -m "micromamba v${VERSION}"
git tag -a "v${VERSION}" -m "micromamba v${VERSION}"
git push origin --tags

