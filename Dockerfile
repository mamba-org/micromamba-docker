ARG BASE_IMAGE=debian:buster-slim

FROM curlimages/curl AS unpack
ARG VERSION=0.7.9
RUN curl -L https://micromamba.snakepit.net/api/micromamba/linux-64/$VERSION \
  | tar -xj -C /tmp bin/micromamba

FROM $BASE_IMAGE
COPY --from=unpack /tmp/bin/micromamba /micromamba
RUN /micromamba shell init -s bash -p /root/micromamba
RUN echo "micromamba activate" >> /root/.bashrc
