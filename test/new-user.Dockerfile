ARG BASE_IMAGE=micromamba:test-debian12-slim

FROM $BASE_IMAGE
RUN micromamba install -y -n base -c conda-forge \
       python=3.12.7 && \
    micromamba clean --all --yes

USER root

RUN if grep -q '^ID=alpine$' /etc/os-release; then \
      adduser testuser -s /bin/bash -D; \
    else \
      useradd -ms /bin/bash testuser; \
    fi

USER testuser
