ARG BASE_IMAGE=debian:buster-slim

FROM curlimages/curl AS unpack
ARG VERSION=0.7.9
RUN curl -L https://micromamba.snakepit.net/api/micromamba/linux-64/$VERSION | \
    tar -xj -C /tmp bin/micromamba

FROM $BASE_IMAGE
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV MAMBA_ROOT_PREFIX=/opt/conda
ENV PATH $MAMBA_ROOT_PREFIX/bin:$MAMBA_ROOT_PREFIX/condabin:$PATH
CMD ["/bin/bash"]

COPY --from=unpack /tmp/bin/micromamba /bin/micromamba

RUN ln -s /bin/micromamba /bin/mamba && \
    ln -s /bin/micromamba /bin/conda && \
    ln -s /bin/micromamba /bin/miniconda && \
    mkdir -p $(dirname $MAMBA_ROOT_PREFIX) && \
    /bin/micromamba shell init -s bash -p $MAMBA_ROOT_PREFIX && \
    ln -s $MAMBA_ROOT_PREFIX/etc/profile.d/mamba.sh /etc/profile.d/mamba.sh && \
    echo "source $MAMBA_ROOT_PREFIX/etc/profile.d/mamba.sh" >> ~/.bashrc && \
    echo "micromamba activate base" >> ~/.bashrc


