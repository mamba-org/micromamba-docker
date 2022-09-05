ARG BASE_IMAGE=micromamba:test-debian-bullseye-slim

FROM $BASE_IMAGE

RUN micromamba install --yes --name base --channel conda-forge \
      conda \
      mamba && \
    micromamba clean --all --yes

ENV PATH=/opt/conda/bin:$PATH
