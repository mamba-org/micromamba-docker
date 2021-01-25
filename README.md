# micromamba_docker
[Micromamba](https://github.com/mamba-org/mamba#micromamba) for fast building of small [conda](https://docs.conda.io/)-based containers. 

Images available on [Dockerhub](https://hub.docker.com/) at [willholtz/micromamba](https://hub.docker.com/r/willholtz/micromamba). Source code on [GitHub](https://github.com/) at [buildcrew/micromamba_docker](https://github.com/buildcrew/micromamba_docker/).

## Typical Usage

### From a yaml spec file

1. Create define your desired environment in a spec file:

```
name: base
channels:
  - anaconda
dependencies:
  - python=3.9.1
  - requests=2.25.1
  - pyopenssl=20.0.1
```

2. Install from the spec file in your Dockerfile:

```
FROM willholtz/micromamba
COPY env.yaml /root/env.yaml
RUN micromamba install -y -n base -f /root/env.yaml
```

### Spec passed on command line

1. Pass package names in a RUN command in your Dockerfile:

```
FROM willholtz/micromamba
RUN micromamba install -y -n base -c anaconda \
    python=3.9.1 \
    requests=2.25.1 \
    pyopenssl=20.0.1

```

## Parent container choice

As noted in the [micromamba documentation](https://github.com/mamba-org/mamba/blob/master/docs/source/micromamba.md#Installation), even though this image uses a (partially) staticaly linked binary, a glibc system is required. Therefore Alpine Linux does not work natively. To keep the image small, a Debian slim image is used as the parent. On going efforts to generate a fully statically linked binary are documented in [mamba github issue #572](https://github.com/mamba-org/mamba/issues/572). If the offical micromamba builds become fully statically linked, then this repo will add images with parent image Alpine or scratch.
