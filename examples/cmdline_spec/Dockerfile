FROM mambaorg/micromamba:1.5.6
RUN micromamba install -y -n base -c conda-forge \
       pyopenssl=20.0.1 \
       python=3.9.1 \
       requests=2.25.1 && \
    micromamba clean --all --yes
