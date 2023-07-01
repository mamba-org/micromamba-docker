ARG BASE_IMAGE=debian:bullseye-slim

# Mutli-stage build to keep final image small. Otherwise end up with
# curl and openssl installed
FROM --platform=$BUILDPLATFORM $BASE_IMAGE AS stage1
ARG VERSION=1.4.6

# hadolint ignore=DL3018
RUN if grep -q '^ID=alpine$' /etc/os-release; then \
       apk add --no-cache \
         bash \
         bzip2 \
         curl; \
    else \
      apt-get update && apt-get install -y --no-install-recommends \
        bzip2 \
        ca-certificates \
        curl \
      && rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log; \
   fi
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG TARGETARCH
RUN test "$TARGETARCH" = 'amd64' && export ARCH='64'; \
    test "$TARGETARCH" = 'arm64' && export ARCH='aarch64'; \
    test "$TARGETARCH" = 'ppc64le' && export ARCH='ppc64le'; \
    curl -L "https://micromamba.snakepit.net/api/micromamba/linux-${ARCH}/${VERSION}" | \
    tar -xj -C "/tmp" "bin/micromamba"

FROM $BASE_IMAGE

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV ENV_NAME="base"
ENV MAMBA_ROOT_PREFIX="/opt/conda"
ENV MAMBA_EXE="/bin/micromamba"

COPY --from=stage1 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=stage1 /tmp/bin/micromamba "$MAMBA_EXE"

# hadolint ignore=DL3018
RUN { grep -q '^ID=alpine$' /etc/os-release && apk add --no-cache bash; } || true

ARG MAMBA_USER=mambauser
ARG MAMBA_USER_ID=1000
ARG MAMBA_USER_GID=1000
ENV MAMBA_USER=$MAMBA_USER

COPY _dockerfile_initialize_user_accounts.sh /usr/local/bin/_dockerfile_initialize_user_accounts.sh
COPY _dockerfile_setup_root_prefix.sh /usr/local/bin/_dockerfile_setup_root_prefix.sh

RUN /usr/local/bin/_dockerfile_initialize_user_accounts.sh && \
    /usr/local/bin/_dockerfile_setup_root_prefix.sh

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
