FROM mambaorg/micromamba:0.8.2
COPY env1.yaml /root/env1.yaml
COPY env2.yaml /root/env2.yaml
RUN micromamba create -y -f /root/env1.yaml && \
    micromamba create -y -f /root/env2.yaml && \
    rm /opt/conda/pkgs/cache/*

