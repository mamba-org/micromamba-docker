# micromamba-docker
[Micromamba](https://github.com/mamba-org/mamba#micromamba) for fast building of small [conda](https://docs.conda.io/)-based containers. 

Images available on [Dockerhub](https://hub.docker.com/) at [mambaorg/micromamba](https://hub.docker.com/r/mambaorg/micromamba). Source code on [GitHub](https://github.com/) at [mamba-org/micromamba-docker](https://github.com/mamba-org/micromamba-docker/).

"This is amazing. I switched CI for my projects to micromamba, and compared to using a miniconda docker image, this reduced build times more than 2x" -- A new micromamba-docker user

## Usage

### Single environment

Use the 'base' environment if you will only have a single environment in your container, as this environment already exists and is activated by default.

#### From a yaml spec file

1. Define your desired environment in a spec file:

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
FROM mambaorg/micromamba:0.14.0
COPY env.yaml /tmp/env.yaml
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes
```

#### Spec passed on command line

1. Pass package names in a RUN command in your Dockerfile:

```
FROM mambaorg/micromamba:0.14.0
RUN micromamba install -y -n base -c conda-forge \
       pyopenssl=20.0.1  \
       python=3.9.1 \
       requests=2.25.1 && \
    micromamba clean --all --yes
```

### Multiple environments

This is not a common usage. Most use cases have a single environment per derived image.

```
FROM mambaorg/micromamba:0.14.0
COPY env1.yaml /tmp/env1.yaml
COPY env2.yaml /tmp/env2.yaml
RUN micromamba create -y -f /tmp/env1.yaml && \
    micromamba create -y -f /tmp/env2.yaml && \
    micromamba clean --all --yes
```

You can then set the active environment by passing the `ENV_NAME` environment variable like:
```
docker run -e ENV_NAME=env2 micromamba
```

### Changing the user

Prior to June 30, 2021, the image defaulted to running as root. Now it defaults to running as the non-root user micromamba. Micromamba-docker can be run as any user by passing the `docker run ...` command the `--user=UID:GID` parameters. Running with `--user=root` is supported.

### Minimizing final image size

Uwe Korn has a nice [blog post on making small containers containing conda environments](https://uwekorn.com/2021/03/01/deploying-conda-environments-in-docker-how-to-do-it-right.html) that is a good resource. He uses mamba instead of micromamba, but the general concepts still apply when using micromamba.

## Development

### Testing

The [Bats](https://github.com/bats-core/bats-core) testing framework is used to test the micromamba docker
images and derived images. When cloning this repo you'll want to use `git clone --recurse-submodules ...`,
which will bring in the git submodules for Bats. With the submodules present, `./test.sh` will run the test
suite. If GNU `parallel` is present, then the test suite will be run in parallel using all logical CPU cores
available.

### Parent container choice

As noted in the [micromamba documentation](https://github.com/mamba-org/mamba/blob/master/docs/source/micromamba.md#Installation), the official micromamba binaries require glibc. Therefore Alpine Linux does not work natively. To keep the image small, a Debian slim image is used as the parent. On going efforts to generate a fully statically linked micromamba binary are documented in [mamba github issue #572](https://github.com/mamba-org/mamba/issues/572), but most conda packages also depend on glibc. Therefore using a statically linked micromamba would require either a method to install glibc (or an equivalent) from a conda package or conda packages that are statically linked against glibc.
