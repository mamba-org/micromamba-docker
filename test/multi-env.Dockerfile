ARG BASE_IMAGE=micromamba:test-debian-bullseye-slim

FROM $BASE_IMAGE
COPY env1.yaml /tmp/env1.yaml
COPY env2.yaml /tmp/env2.yaml
RUN micromamba create -y -f /tmp/env1.yaml && \
    micromamba create -y -f /tmp/env2.yaml && \
    micromamba clean --all --yes

