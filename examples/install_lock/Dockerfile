FROM mambaorg/micromamba:2.0.6

COPY --chown=$MAMBA_USER:$MAMBA_USER env.lock /tmp/env.lock
RUN micromamba install --name base --yes --file /tmp/env.lock \
    && micromamba clean --all --yes
