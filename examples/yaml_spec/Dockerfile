FROM mambaorg/micromamba:0.7.14
COPY env.yaml /root/env.yaml
RUN micromamba install -y -n base -f /root/env.yaml && \
    rm /opt/conda/pkgs/cache/*
