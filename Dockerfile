ARG BASE_IMAGE=debian:bullseye-slim

# Mutli-stage build to keep final image small. Otherwise end up with
# curl and openssl installed
FROM --platform=$BUILDPLATFORM $BASE_IMAGE AS stage1
ARG VERSION=0.19.1
RUN apt-get update && apt-get install -y \
    bzip2 \
    ca-certificates \
    curl \
    && rm -rf /var/lib/{apt,dpkg,cache,log}
ARG TARGETARCH
RUN [ $TARGETARCH = 'amd64' ] && export ARCH='64'; \
    [ $TARGETARCH = 'arm64' ] && export ARCH='aarch64'; \
    [ $TARGETARCH = 'ppc64le' ] && export ARCH='ppc64le'; \
    curl -L https://micromamba.snakepit.net/api/micromamba/linux-$ARCH/$VERSION | \
    tar -xj -C /tmp bin/micromamba

FROM $BASE_IMAGE

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV ENV_NAME="base"
ENV MAMBA_ROOT_PREFIX="/opt/conda"
ENV MAMBA_EXE="/bin/micromamba"

COPY --from=stage1 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=stage1 /tmp/bin/micromamba "$MAMBA_EXE"

RUN echo "source _activate_current_env.sh" >> ~/.bashrc && \
    echo "source _activate_current_env.sh" >> /etc/skel/.bashrc && \
    useradd -ms /bin/bash micromamba && \
    mkdir -p "$MAMBA_ROOT_PREFIX" && \
    chmod -R a+rwx "$MAMBA_ROOT_PREFIX" "/home"

USER micromamba
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
