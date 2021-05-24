FROM mambaorg/micromamba:0.13.1
COPY env1.yaml /root/env1.yaml
COPY env2.yaml /root/env2.yaml
RUN micromamba create -y -f /root/env1.yaml && \
    micromamba create -y -f /root/env2.yaml && \
    micromamba clean --all --yes

