ARG BASE_IMAGE=micromamba:test-debian12-slim

FROM $BASE_IMAGE

ARG NEW_MAMBA_USER
ARG NEW_MAMBA_USER_ID=57440
ARG NEW_MAMBA_USER_GID=57440
USER root

# hadolint ignore=DL3018
RUN if grep -q '^ID=alpine$' /etc/os-release; then \
      echo http://dl-2.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories; \
      apk add --no-cache \
         shadow; \
    fi && \
    usermod "--login=${NEW_MAMBA_USER}" "--home=/home/${NEW_MAMBA_USER}" \
        --move-home "-u ${NEW_MAMBA_USER_ID}" "${MAMBA_USER}" && \
    groupmod "--new-name=${NEW_MAMBA_USER}" "-g ${NEW_MAMBA_USER_GID}" "${MAMBA_USER}" && \
    # Update the expected value of MAMBA_USER for the _entrypoint.sh consistency check.
    echo "${NEW_MAMBA_USER}" > "/etc/arg_mamba_user" && \
    :
ENV MAMBA_USER=$NEW_MAMBA_USER
USER $MAMBA_USER
