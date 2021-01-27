FROM willholtz/micromamba:0.7.10
COPY env.yaml /root/env.yaml
RUN micromamba install -y -n base -f /root/env.yaml && \
    rm /opt/conda/pkgs/cache/*
