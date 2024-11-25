FROM mambaorg/micromamba:2.0.4

RUN micromamba install -y -n base -c conda-forge \
       pyopenssl=20.0.1 \
       python=3.12.7 \
       requests=2.25.1 && \
    micromamba clean --all --yes
