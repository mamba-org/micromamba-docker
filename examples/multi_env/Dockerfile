FROM mambaorg/micromamba:0.15.3
COPY --chown=micromamba:micromamba env1.yaml /tmp/env1.yaml
COPY --chown=micromamba:micromamba env2.yaml /tmp/env2.yaml
RUN micromamba create -y -f /tmp/env1.yaml && \
    micromamba create -y -f /tmp/env2.yaml && \
    micromamba clean --all --yes

