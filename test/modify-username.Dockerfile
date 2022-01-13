FROM micromamba:test

ARG NEW_MAMBA_USER
USER root
RUN usermod "--login=${NEW_MAMBA_USER}" "--home=/home/${MAMBA_USER}" \
        --move-home "${MAMBA_USER}" && \
    groupmod "--new-name=${NEW_MAMBA_USER}" "${MAMBA_USER}" && \
    # Update the expected value of MAMBA_USER for the _entrypoint.sh consistency check.
    echo "${NEW_MAMBA_USER}" > "/etc/arg_mamba_user" && \
    :
ENV MAMBA_USER=$NEW_MAMBA_USER
USER $MAMBA_USER
