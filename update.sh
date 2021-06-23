#!/bin/bash

set -euf -o pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 version"
  exit 1
fi

VERSION="$1"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

DOCKERFILES=$(find . -not -path "./test/bats/*" -name '*Dockerfile')

git checkout -b "release${VERSION}"

for f in $DOCKERFILES; do
  sed -i.bak  "s%^FROM mambaorg/micromamba:.*$%FROM mambaorg/micromamba:${VERSION}%" "$f"
  rm "$f.bak"
done

sed -i.bak "s%mambaorg/micromamba:.*$%mambaorg/micromamba:${VERSION}%" "${SCRIPT_DIR}/README.md"
rm "${SCRIPT_DIR}/README.md.bak"

git add README.md $DOCKERFILES
git commit -m "micromamba v${VERSION}"
git push origin
git tag -a "v${VERSION}" -m "micromamba v${VERSION}"
git push origin --tags
