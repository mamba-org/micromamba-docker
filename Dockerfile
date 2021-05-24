ARG BASE_IMAGE=debian:buster-slim

# Mutli-stage build to keep final image small. Otherwise end up with
# curl and openssl installed
FROM --platform=$BUILDPLATFORM debian:buster-slim AS stage1
ARG VERSION=0.13.1
RUN apt-get update && apt-get install -y \
    bzip2 \
    ca-certificates \
    curl \
    && rm -rf /var/lib/{apt,dpkg,cache,log}
ARG TARGETARCH
RUN [ $TARGETARCH = 'arm64' ] && export ARCH='aarch64' || export ARCH='64' && \
    curl -L https://micromamba.snakepit.net/api/micromamba/linux-$ARCH/$VERSION | \
    tar -xj -C /tmp bin/micromamba

FROM $BASE_IMAGE

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV ENV_NAME="base"
ENV MAMBA_ROOT_PREFIX="/opt/conda"
ENV HOME="/home/micromamba"
ENV BASH_ENV="$HOME/.bashrc"

# Setting $BASH_ENV and the SHELL command will not result in .bashrc being sourced when
# you supply the program to run as an argument to the "docker run" command.
# Manually add directory for micromamba installed executables to PATH as a workaround.
ENV PATH "$MAMBA_ROOT_PREFIX/bin:$PATH"

# Use bash in Dockerfile RUN commands and make sure bashrc is sourced when
# executing commands with /bin/bash -c
# Needed to have the micromamba activate command configured etc.
SHELL ["/bin/bash", "-c"]

COPY --from=stage1 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=stage1 /tmp/bin/micromamba /bin/micromamba

RUN mkdir -p "$HOME" && \
    /bin/micromamba shell init -s bash -p "$MAMBA_ROOT_PREFIX" && \
    echo "micromamba activate $ENV_NAME" >> "$BASH_ENV" && \
    chmod -R a+rwx "$HOME" "$BASH_ENV" "$MAMBA_ROOT_PREFIX"

CMD ["/bin/bash"]
