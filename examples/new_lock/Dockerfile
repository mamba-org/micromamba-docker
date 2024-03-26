FROM mambaorg/micromamba:1.5.8
COPY --chown=$MAMBA_USER:$MAMBA_USER env.lock /tmp/env.lock
RUN micromamba create --name my_env_name --yes --file /tmp/env.lock \
    && micromamba clean --all --yes
