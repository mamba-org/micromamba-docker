ARG BASE_IMAGE=debian:bullseye-slim

# Mutli-stage build to keep final image small. Otherwise end up with
# curl and openssl installed
FROM --platform=$BUILDPLATFORM $BASE_IMAGE AS stage1
ARG VERSION=0.18.2
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
ENV PATH "$MAMBA_ROOT_PREFIX/bin:$PATH"

COPY --from=stage1 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=stage1 /tmp/bin/micromamba "$MAMBA_EXE"
COPY entrypoint.sh /bin/entrypoint.sh

RUN useradd -ms /bin/bash micromamba && \
    export ENV_NAME="$ENV_NAME" && \
    mkdir -p "$MAMBA_ROOT_PREFIX" && \
    "$MAMBA_EXE" shell init -p "$MAMBA_ROOT_PREFIX" -s bash > /dev/null && \
    "$MAMBA_EXE" shell completion -s bash > /dev/null && \
    chmod -R a+rwx "$MAMBA_ROOT_PREFIX" "/home" && \
    echo "micromamba activate \$ENV_NAME" >> ~/.bashrc

USER micromamba
RUN "$MAMBA_EXE" shell init -p "$MAMBA_ROOT_PREFIX" -s bash > /dev/null && \
    "$MAMBA_EXE" shell completion -s bash > /dev/null && \
    echo "micromamba activate \$ENV_NAME" >> ~/.bashrc

WORKDIR /tmp
ENTRYPOINT ["/bin/entrypoint.sh"]
CMD ["/bin/bash"]
