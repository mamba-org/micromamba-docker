FROM mambaorg/micromamba:2.0.6

COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    bluetooth \
    && rm -rf /var/lib/apt/lists/*
USER $MAMBA_USER
