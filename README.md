# micromamba-docker

[Micromamba](https://github.com/mamba-org/mamba#micromamba) for fast building of small [conda](https://docs.conda.io/)-based containers.

Images available on [Dockerhub](https://hub.docker.com/) at [mambaorg/micromamba](https://hub.docker.com/r/mambaorg/micromamba). Source code on [GitHub](https://github.com/) at [mamba-org/micromamba-docker](https://github.com/mamba-org/micromamba-docker/).

"This is amazing. I switched CI for my projects to micromamba, and compared to using a miniconda docker image, this reduced build times more than 2x" -- A new micromamba-docker user

## Quick start

The micromamba image comes with an empty environment named 'base'. Usually you
will install software into this 'base' environment.

1. Define your desired conda environment in a yaml file:

    ```yaml
    name: base
    channels:
      - conda-forge
    dependencies:
      - pyopenssl=20.0.1
      - python=3.9.1
      - requests=2.25.1
    ```

2. Copy the yaml file to your docker image and pass it to micromamba

    ```Dockerfile
    FROM mambaorg/micromamba:0.19.0
    COPY --chown=micromamba:micromamba env.yaml /tmp/env.yaml
    RUN micromamba install -y -f /tmp/env.yaml && \
        micromamba clean --all --yes
    ```

3. Build your docker image
  
    The 'base' conda environment is automatically activated when the image
    is running.
  
    ```bash
    $ docker build --quiet --tag my_app .
    sha256:b04d00cd5e7ab14f97217c24bc89f035db33a8d339bfb9857698d9390bc66cf8
    $ docker run -it --rm my_app python --version
    3.9.1
    ```

### Using RUN execute software within conda environments

To `RUN` a command from a conda environment within a Dockerfile, you *must*:

1. Set `ARG MAMBA_DOCKERFILE_ACTIVATE=1` to activate the conda environment
1. Use the 'shell' form of the `RUN` command

#### Activating a conda environment for RUN commands

No conda environment is automatically activated during the execution
of `RUN` commands within a Dockerfile. To have an environment active during
a `RUN`command, you must set `ARG MAMBA_DOCKERFILE_ACTIVATE=1`. For example:

```Dockerfile
FROM mambaorg/micromamba:0.19.0
COPY --chown=micromamba:micromamba env.yaml /tmp/env.yaml
RUN micromamba install -y -f /tmp/env.yaml && \
    micromamba clean --all --yes
ARG MAMBA_DOCKERFILE_ACTIVATE=1
RUN python -c 'import uuid; print(uuid.uuid4())' > /tmp/my_uuid
```

#### Use the shell form of RUN with micromamba

The Dockerfile `RUN` command can be invoked in the 'shell' form:

```Dockerfile
RUN python -c "import uuid; print(uuid.uuid4())"
```

And the 'exec' form:

```Dockerfile
RUN ["python", "-c", "import uuid; print(uuid.uuid4())"]
```

You *must* use the 'shell' form of `RUN` or the command will not execute in
the context of a conda environment.

## Advanced Usages

### Pass list of packages to install within a Dockerfile RUN command

```Dockerfile
FROM mambaorg/micromamba:0.19.0
RUN micromamba install -y -n base -c conda-forge \
      pyopenssl=20.0.1  \
      python=3.9.1 \
      requests=2.25.1 && \
    micromamba clean --all --yes
```

### Multiple environments

For most use cases you will only want a single conda environment within your
derived image, but you can create multiple conda environments:

```Dockerfile
FROM mambaorg/micromamba:0.19.0
COPY --chown=micromamba:micromamba env1.yaml /tmp/env1.yaml
COPY --chown=micromamba:micromamba env2.yaml /tmp/env2.yaml
RUN micromamba create -y -f /tmp/env1.yaml && \
    micromamba create -y -f /tmp/env2.yaml && \
    micromamba clean --all --yes
```

You can then set the active environment by passing the `ENV_NAME` environment variable like:

```bash
docker run -e ENV_NAME=env2 my_multi_conda_image
```

### Changing the user

Prior to June 30, 2021, the image defaulted to running as root. Now it defaults to running as the non-root user micromamba. Micromamba-docker can be run as any user by passing the `docker run ...` command the `--user=UID:GID` parameters. Running with `--user=root` is supported.

## Minimizing final image size

Uwe Korn has a nice [blog post on making small containers containing conda environments](https://uwekorn.com/2021/03/01/deploying-conda-environments-in-docker-how-to-do-it-right.html) that is a good resource. He uses mamba instead of micromamba, but the general concepts still apply when using micromamba.

## Support

Please open an [issue](https://github.com/mamba-org/micromamba-docker/issues) if the micromamba docker image does not behave as you expect. For issues about the micromamba program, please use [the mamba issue tracker](https://github.com/mamba-org/mamba/issues).

## Contributing

This project is a community effort and contributions are welcome. Best practice is to discuss proposed contributions on the [issue tracker](https://github.com/mamba-org/micromamba-docker/issues) before you start writing code.

## Development

### Testing

The [Bats](https://github.com/bats-core/bats-core) testing framework is used to test the micromamba docker
images and derived images. When cloning this repo you'll want to use `git clone --recurse-submodules ...`,
which will bring in the git submodules for Bats. With the submodules present, `./test.sh` will run the test
suite. If GNU `parallel` is present, then the test suite will be run in parallel using all logical CPU cores
available.

### Roadmap

The current roadmap for expanding the number of base images is as follows:

1. Add all releases of debian slim that have not yet reached LTS end of life (ie, bullseye, buster, stretch)
1. Add the non-slim debian image
1. Add other debian based distros that have community interest (such as ubuntu)
1. Add non-debian based distros that have community interest

The build and test infrastructure will need to be altered to support additional
base images such that automated test and build occur for all images produced.

### Policies

1. Entrypoint script should not write to files in the home directory. On some container execution systems, the host home directory is automatically mounted and we don't want to mess up or pollute the home directory on the host system.

### Parent container choice

As noted in the [micromamba documentation](https://github.com/mamba-org/mamba/blob/master/docs/source/micromamba.md#Installation), the official micromamba binaries require glibc. Therefore Alpine Linux does not work natively. To keep the image small, a Debian slim image is used as the parent. On going efforts to generate a fully statically linked micromamba binary are documented in [mamba github issue #572](https://github.com/mamba-org/mamba/issues/572), but most conda packages also depend on glibc. Therefore using a statically linked micromamba would require either a method to install glibc (or an equivalent) from a conda package or conda packages that are statically linked against glibc.
