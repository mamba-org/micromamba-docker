FROM mambaorg/micromamba:2.0.6

RUN micromamba install -y -n base -c conda-forge \
       pyopenssl=24.3.0 \
       python=3.12.7 \
       requests=2.32.3 && \
    micromamba clean --all --yes
