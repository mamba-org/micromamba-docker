# micromamba-docker
[Micromamba](https://github.com/mamba-org/mamba#micromamba) for fast building of small [conda](https://docs.conda.io/)-based containers. 

Images available on [Dockerhub](https://hub.docker.com/) at [mambaorg/micromamba](https://hub.docker.com/r/mambaorg/micromamba). Source code on [GitHub](https://github.com/) at [mamba-org/micromamba-docker](https://github.com/mamba-org/micromamba-docker/).

"This is amazing. I switched CI for my projects to micromamba, and compared to using a miniconda docker image, this reduced build times more than 2x" -- A new micromamba-docker user

## Typical usage - single environment

Use the 'base' environment if you will only have a single environment in your container, as this environment already exists and is activated by default.

### From a yaml spec file

1. Create define your desired environment in a spec file:

```
name: base
channels:
  - conda-forge
dependencies:
  - pyopenssl=20.0.1
  - python=3.9.1
  - requests=2.25.1
```

2. Install from the spec file in your Dockerfile:

```
FROM mambaorg/micromamba:0.11.3
COPY env.yaml /root/env.yaml
RUN micromamba install -y -n base -f /root/env.yaml && \
    micromamba clean --all --yes
```

### Spec passed on command line

1. Pass package names in a RUN command in your Dockerfile:

```
FROM mambaorg/micromamba:0.11.3
RUN micromamba install -y -n base -c conda-forge \
       pyopenssl=20.0.1  \
       python=3.9.1 \
       requests=2.25.1 && \
    micromamba clean --all --yes
```

## Multiple environments

```
FROM mambaorg/micromamba:0.11.3
COPY env1.yaml /root/env1.yaml
COPY env2.yaml /root/env2.yaml
RUN micromamba create -y -f /root/env1.yaml && \
    micromamba create -y -f /root/env2.yaml && \
    micromamba clean --all --yes
```

You will then need to use `micromamba activate envX` to activate env1 or env2. But don't put that `micromamba activate envX` in a Dockerfile RUN command, as it is only valid for the current invocation of your shell.


## Minimizing final image size

Uwe Korn has a nice [blog post on making small containers containing conda environments](https://uwekorn.com/2021/03/01/deploying-conda-environments-in-docker-how-to-do-it-right.html) that is a good resource. He uses mamba instead of micromamba, but the general concepts still apply when using micromamba.

### Parent container choice

As noted in the [micromamba documentation](https://github.com/mamba-org/mamba/blob/master/docs/source/micromamba.md#Installation), the offical micromamba binaries require glibc. Therefore Alpine Linux does not work natively. To keep the image small, a Debian slim image is used as the parent. On going efforts to generate a fully statically linked micromamba binary are documented in [mamba github issue #572](https://github.com/mamba-org/mamba/issues/572), but most conda packages also depend on glibc. Therefore using a statically linked micromamba would require either a method to install glibc i(or an equivalent) from a conda package or conda packages that are statically linked against glibc.

## Contributors and Acknowledgements

The following people have directly or indirectly contributed to this project:
* Will Holtz
* Wolf Vollprecht
* Thomas Buhrmann (via [this github comment](https://gist.github.com/wolfv/fe1ea521979973ab1d016d95a589dcde#gistcomment-3525280))
