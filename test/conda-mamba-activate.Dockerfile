ARG BASE_IMAGE=micromamba:test-debian12-slim

FROM $BASE_IMAGE

RUN micromamba install --yes --name base --channel conda-forge \
      conda \
      mamba && \
    micromamba clean --all --yes
