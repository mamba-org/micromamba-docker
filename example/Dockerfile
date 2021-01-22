FROM micromamba

COPY env.yaml /root/env.yaml
RUN /bin/bash -c 'source $HOME/.bashrc \
    && micromamba install -y -f /root/env.yaml'
