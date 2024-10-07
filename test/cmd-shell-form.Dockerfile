ARG BASE_IMAGE=micromamba:test-debian12-slim

FROM $BASE_IMAGE
RUN micromamba install -y -n base -c conda-forge \
       python=3.9.1  && \
    micromamba clean --all --yes

# hadolint ignore=DL3025
CMD python -c "print('hello')"
