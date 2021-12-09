#!/bin/bash

set -euf -o pipefail

function display_help {
  echo ""
  echo -e "Usage: $0 [options] version"
  echo ""
  echo "   version                 version number of micromamba to include in image (required)"
  echo "   -h, --help              show this command reference"
  echo "   -c, --commit            make a git commit, tag it, and push to origin "
  echo ""
}

function unknown_param {
  echo ""
  echo "ERROR: Unknown parameter passed: $1"
  display_help
  exit 2
}

if [[ $# -eq 0 ]]; then
  display_help
  exit 1
fi

VERSION=""
COMMIT=""
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -c|--commit) COMMIT="TRUE" ;;
    -h|--help) display_help; exit 0 ;;
    -*) unknown_param "$1" ;;
    *) [ -z "${VERSION}" ] && VERSION="$1" || unknown_param "$1" ;;
  esac
  shift
done

if [ -z "${VERSION}"  ]; then
  echo $'\nERROR: No version value passed'
  display_help
  exit 3
fi

BRANCH="release${VERSION}"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

DOCKERFILES=$(find . -not -path "./test/bats/*" -name '*Dockerfile')

if [ "$COMMIT" = "TRUE" ]; then
  git checkout main
  git pull
  git checkout -b "$BRANCH"
fi

for f in $DOCKERFILES; do
  sed -i.bak  "s%^FROM mambaorg/micromamba:.*$%FROM mambaorg/micromamba:${VERSION}%" "$f"
  rm "$f.bak"
done

sed -i.bak  "s%^ARG VERSION=.*$%ARG VERSION=${VERSION}%" "${SCRIPT_DIR}/Dockerfile"
rm "${SCRIPT_DIR}/Dockerfile.bak"

sed -i.bak "s%mambaorg/micromamba:.*$%mambaorg/micromamba:${VERSION}%" "${SCRIPT_DIR}/README.md"
rm "${SCRIPT_DIR}/README.md.bak"

if [ "$COMMIT" = "TRUE" ]; then
  git add README.md $DOCKERFILES
  git commit -m "micromamba v${VERSION}"
  git push --set-upstream origin "$BRANCH"
  git tag -a "v${VERSION}" -m "micromamba v${VERSION}"
  git push --set-upstream origin "$BRANCH" --tags
fi
