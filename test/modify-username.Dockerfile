FROM micromamba:test

ARG NEW_MAMBA_USER
USER root
RUN usermod "--login=${NEW_MAMBA_USER}" "${MAMBA_USER}" && \
    groupmod "--new-name=${NEW_MAMBA_USER}" "${MAMBA_USER}" && \
    mv "/home/${MAMBA_USER}" "/home/${NEW_MAMBA_USER}" && \
    # Disables the consistency check in _entrypoint.sh:
    rm "/etc/arg_mamba_user" && \
    :
ENV MAMBA_USER=$NEW_MAMBA_USER
USER $MAMBA_USER
