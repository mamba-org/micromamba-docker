FROM mambaorg/micromamba:0.19.1
COPY --chown=micromamba:micromamba env.yaml /tmp/env.yaml
RUN micromamba install -y -f /tmp/env.yaml && \
    micromamba clean --all --yes
