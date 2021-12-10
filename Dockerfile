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

RUN useradd -ms /bin/bash micromamba && \
    mkdir -p "$MAMBA_ROOT_PREFIX" && \
    "$MAMBA_EXE" shell init -p "$MAMBA_ROOT_PREFIX" -s bash > /dev/null && \
    chmod -R a+rwx "$MAMBA_ROOT_PREFIX" "/home" && \
    echo "micromamba activate \$ENV_NAME" >> ~/.bashrc

USER micromamba
RUN "$MAMBA_EXE" shell init -p "$MAMBA_ROOT_PREFIX" -s bash > /dev/null && \
    echo "micromamba activate \$ENV_NAME" >> ~/.bashrc

WORKDIR /tmp

# Script which launches commands passed to "docker run"
COPY _entrypoint.sh /bin/_entrypoint.sh
ENTRYPOINT ["/bin/_entrypoint.sh"]

# Default command for "docker run"
CMD ["/bin/bash"]

# Script which launches RUN commands in Dockerfile
COPY _dockerfile_shell.sh /bin/_dockerfile_shell.sh
SHELL ["/bin/_dockerfile_shell.sh"]
