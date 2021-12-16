FROM micromamba:test
RUN micromamba install -y -n base -c conda-forge \
       python=3.9.1  && \
    micromamba clean --all --yes

USER root

RUN useradd -ms /bin/bash testuser

USER testuser
