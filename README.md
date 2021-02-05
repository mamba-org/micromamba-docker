# micromamba-docker
[Micromamba](https://github.com/mamba-org/mamba#micromamba) for fast building of small [conda](https://docs.conda.io/)-based containers. 

Images available on [Dockerhub](https://hub.docker.com/) at [mambaorg/micromamba](https://hub.docker.com/r/mambaorg/micromamba). Source code on [GitHub](https://github.com/) at [mamba-org/micromamba-docker](https://github.com/mamba-org/micromamba-docker/).

## Typical Usage

### From a yaml spec file

1. Create define your desired environment in a spec file:

```
name: base
channels:
  - anaconda
dependencies:
  - pyopenssl=20.0.1
  - python=3.9.1
  - requests=2.25.1
```

2. Install from the spec file in your Dockerfile:

```
FROM mambaorg/micromamba:0.7.12
COPY env.yaml /root/env.yaml
RUN micromamba install -y -n base -f /root/env.yaml && \
    rm /opt/conda/pkgs/cache/*
```

### Spec passed on command line

1. Pass package names in a RUN command in your Dockerfile:

```
FROM mambaorg/micromamba:0.7.12
RUN micromamba install -y -n base -c anaconda \
       pyopenssl=20.0.1  \
       python=3.9.1 \
       requests=2.25.1 && \
    rm /opt/conda/pkgs/cache/*

```

## Parent container choice

As noted in the [micromamba documentation](https://github.com/mamba-org/mamba/blob/master/docs/source/micromamba.md#Installation), the offical micromamba binaries require glibc. Therefore Alpine Linux does not work natively. To keep the image small, a Debian slim image is used as the parent. On going efforts to generate a fully statically linked micromamba binary are documented in [mamba github issue #572](https://github.com/mamba-org/mamba/issues/572), but most conda packages also depend on glibc. Therefore using a statically linked micromamba would require either a method to install glibc i(or an equivalent) from a conda package or conda packages that are statically linked against glibc.

## Contributors and Acknowledgements

The following people have directly or indirectly contributed to this project:
* Will Holtz
* Wolf Vollprecht
* Thomas Buhrmann (via [this github comment](https://gist.github.com/wolfv/fe1ea521979973ab1d016d95a589dcde#gistcomment-3525280))
