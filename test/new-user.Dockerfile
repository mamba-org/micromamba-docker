ARG BASE_IMAGE=micromamba:test-debian-bullseye-slim

FROM $BASE_IMAGE
RUN micromamba install -y -n base -c conda-forge \
       python=3.9.1  && \
    micromamba clean --all --yes

USER root

RUN if grep -q '^ID=alpine$' /etc/os-release; then \
      adduser testuser -s /bin/bash -D; \
    else \
      useradd -ms /bin/bash testuser; \
    fi

USER testuser
