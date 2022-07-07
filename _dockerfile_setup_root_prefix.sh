#!/bin/bash

set -euf -o pipefail

mkdir -p "$MAMBA_ROOT_PREFIX/conda-meta"
chmod -R a+rwx "$MAMBA_ROOT_PREFIX"
