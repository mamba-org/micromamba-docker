FROM mambaorg/micromamba:0.13.1
COPY env.yaml /root/env.yaml
RUN micromamba install -y -n base -f /root/env.yaml && \
    micromamba clean --all --yes
