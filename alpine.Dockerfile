ARG BASE_IMAGE=frolvlad/alpine-glibc:alpine-3.20

# Mutli-stage build to keep final image small. Otherwise end up with
# curl and openssl installed
FROM $BASE_IMAGE AS stage1
ARG TARGETARCH
ARG VERSION=2.0.6
# hadolint ignore=DL3018
RUN apk add --no-cache \
      bash \
      bzip2 \
      curl
COPY _download_micromamba.sh /usr/local/bin/
RUN _download_micromamba.sh

FROM $BASE_IMAGE AS stage2

ARG CERT_SOURCE='/etc/ssl/certs/ca-certificates.crt'
ARG MAMBA_USER=mambauser
ARG MAMBA_USER_ID=57439
ARG MAMBA_USER_GID=57439
ENV MAMBA_USER=$MAMBA_USER
ENV MAMBA_USER_ID=$MAMBA_USER_ID
ENV MAMBA_USER_GID=$MAMBA_USER_GID
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV ENV_NAME="base"
ENV MAMBA_ROOT_PREFIX="/opt/conda"
ENV MAMBA_EXE="/bin/micromamba"

COPY --from=stage1 "${MAMBA_EXE}" "${MAMBA_EXE}"
COPY --from=stage1 "${CERT_SOURCE}" "${CERT_SOURCE}"
COPY _dockerfile_initialize_user_accounts.sh /usr/local/bin/_dockerfile_initialize_user_accounts.sh
COPY _dockerfile_setup_root_prefix.sh /usr/local/bin/_dockerfile_setup_root_prefix.sh

# hadolint ignore=DL3018
RUN apk add --no-cache \
      bash \
    && /usr/local/bin/_dockerfile_initialize_user_accounts.sh \
    && /usr/local/bin/_dockerfile_setup_root_prefix.sh

USER $MAMBA_USER

WORKDIR /tmp

# Script which launches commands passed to "docker run"
COPY _entrypoint.sh /usr/local/bin/_entrypoint.sh
COPY _activate_current_env.sh /usr/local/bin/_activate_current_env.sh
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh"]

# Default command for "docker run"
CMD ["/bin/bash"]

# Script which launches RUN commands in Dockerfile
COPY _dockerfile_shell.sh /usr/local/bin/_dockerfile_shell.sh
SHELL ["/usr/local/bin/_dockerfile_shell.sh"]
