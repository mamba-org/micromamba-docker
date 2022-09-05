ARG BASE_IMAGE=micromamba:test-debian-bullseye-slim

FROM $BASE_IMAGE

ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN micromamba install -y -c conda-forge conda mamba

# Test conda init
RUN bash -c "conda init && bash -c 'conda activate base'"

# Test mamba init
RUN bash -c "mamba init && bash -c 'mamba activate base'"
