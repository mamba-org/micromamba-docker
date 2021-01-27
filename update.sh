#!/bin/bash

set -euf -o pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 version"
  exit 1
fi

VERSION="$1"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

sed -i Dockerfile 's/^ARG VERSION=.*$/ARG VERSION=${VERSION}/'

for f in $(find "${SCRIPT_DIR}/examples" -name Dockerfile); do
  sed -i "$f" 's%^FROM willholtz/micromamba:.*$%FROM willholtz/micromamba:${VERSION}/'
done

sed -i "${SCRIPT_DIR}/README.md" 's%willholtz/micromamba:.*$%willholtz/micromamba:${VERSION}/'

podman build -t "micromamba:${VERSION}" .

git add Dockerfile
git commit -m "micromamba v${VERSION}"
git tag -a "v${VERSION}" -m "micromamba v${VERSION}"
git push origin --tags

