# micromamba-docker

[Micromamba](https://github.com/mamba-org/mamba#micromamba) for fast building of small [conda](https://docs.conda.io/)-based containers.

Images available on [Dockerhub](https://hub.docker.com/) at [mambaorg/micromamba](https://hub.docker.com/r/mambaorg/micromamba). Source code on [GitHub](https://github.com/) at [mamba-org/micromamba-docker](https://github.com/mamba-org/micromamba-docker/).

"This is amazing. I switched CI for my projects to micromamba, and compared to using a miniconda docker image, this reduced build times more than 2x" -- A new micromamba-docker user

## About the image

The micromamba image is currently derived from the `debian:bullseye-slim` image.
Thus far, the image has been focused on supporting use of the `bash` shell. We
plan to build from additional base images and support additional shells in the
future (see [road map](#road-map)).

### Tags

When a commit pushed to the `main` branch of
[mamba-org/micromamba-docker](https://github.com/mamba-org/micromamba-docker/)
or when a new release of `micromamba` binaries are available on
[conda-forge](https://anaconda.org/conda-forge/micromamba),
new docker images are built and pushed to dockerhub. Each image is tagged with
the version of `micromamba` it contains and these tags will start with a
number. Images are also tagged with `git-<HASH>` where `<HASH>` is the first
7 characters of the git commit hash from the
[mamba-org/micromamba-docker](https://github.com/mamba-org/micromamba-docker/)
git repository.

For reproducible image builds, best practice is for Dockerfile `FROM`
commands to reference the image's sha256 digest and not use tags.

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
    FROM mambaorg/micromamba:0.19.1
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

### Running commands in Dockerfile within the conda environment

While the conda environment is automatically activated for `docker run ...` commands,
it is not automatically activated during build. To `RUN` a command from a conda
environment within a Dockerfile, as explained in detail in the next two subsections,
you *must*:

1. Set `ARG MAMBA_DOCKERFILE_ACTIVATE=1` to activate the conda environment
1. Use the 'shell' form of the `RUN` command

#### Activating a conda environment for RUN commands

No conda environment is automatically activated during the execution
of `RUN` commands within a Dockerfile. To have an environment active during
a `RUN` command, you must set `ARG MAMBA_DOCKERFILE_ACTIVATE=1`. For example:

```Dockerfile
FROM mambaorg/micromamba:0.19.1
COPY --chown=micromamba:micromamba env.yaml /tmp/env.yaml
RUN micromamba install --yes --file /tmp/env.yaml && \
    micromamba clean --all --yes
ARG MAMBA_DOCKERFILE_ACTIVATE=1  # (otherwise python will not be found)
RUN python -c 'import uuid; print(uuid.uuid4())' > /tmp/my_uuid
```

#### Use the shell form of RUN with micromamba

The Dockerfile `RUN` command can be invoked either in the 'shell' form:

```Dockerfile
RUN python -c "import uuid; print(uuid.uuid4())"
```

or the 'exec' form:

```Dockerfile
RUN ["python", "-c", "import uuid; print(uuid.uuid4())"]  # DO NOT USE THIS FORM!
```

You *must* use the 'shell' form of `RUN` or the command will not execute in
the context of a conda environment.

#### Activating a conda environment for ENTRYPOINT commands

The Dockerfile for building the `mambaorg/micromamba` image contains:

``` Dockerfile
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh"]
```

where `_entrypoint.sh` activates the conda environment for any programs
run via `CMD` in a Dockerfile or using
`docker run mambaorg/micromamba my_command` on the command line.
If you were to make an image derived from `mambaorg/micromamba` with:

``` Dockerfile
ENTRYPOINT ["my_command"]
```

then you will have removed the conda activation from the `ENTRYPOINT` and
`my_command` will be executed outside of any conda environment.


If you would like an `ENTRYPOINT` command to be executed within an active conda
environment, then add `"/usr/local/bin/_entrypoint.sh"` as the first element
of the JSON array argument to `ENTRYPOINT`. For example, if you would like
for your `ENTRYPOINT` command to run `python` from a conda environment,
then you would do:

``` Dockerfile
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "python"]
```

## Advanced Usages

### Pass list of packages to install within a Dockerfile RUN command

```Dockerfile
FROM mambaorg/micromamba:0.19.1
RUN micromamba install --yes --name base --channel conda-forge \
      pyopenssl=20.0.1  \
      python=3.9.1 \
      requests=2.25.1 && \
    micromamba clean --all --yes
```

### Multiple environments

For most use cases you will only want a single conda environment within your
derived image, but you can create multiple conda environments:

```Dockerfile
FROM mambaorg/micromamba:0.19.1
COPY --chown=micromamba:micromamba env1.yaml /tmp/env1.yaml
COPY --chown=micromamba:micromamba env2.yaml /tmp/env2.yaml
RUN micromamba create --yes --file /tmp/env1.yaml && \
    micromamba create --yes --file /tmp/env2.yaml && \
    micromamba clean --all --yes
```

You can then set the active environment by passing the `ENV_NAME` environment variable like:

```bash
docker run -e ENV_NAME=env2 my_multi_conda_image
```

### Changing the user

Prior to June 30, 2021, the image defaulted to running as root. Now it defaults to running as the non-root user micromamba. Micromamba-docker can be run as any user by passing the `docker run ...` command the `--user=UID:GID` parameters. Running with `--user=root` is supported.

### Disabling automatic activation

It is assumed that users will want their environment automatically activated whenever
running this container. This behavior can be disabled by setting the environment
variable `MAMBA_SKIP_ACTIVATE=1`.

For example, to open an interactive bash shell without activating the environment:

```bash
docker run --rm -it -e MAMBA_SKIP_ACTIVATE=1 mambaorg/micromamba bash
```

### Details about automatic activation

At container runtime, activation occurs by default at two possible points:

1. The end of the `~/.bashrc` file, which is loaded by interactive non-login Bash shells.
2. The `ENTRYPOINT` script, which is automatically prepended to `docker run` commands.

The activation in `~/.bashrc` ensures that the environment is activated in interactive
terminal sessions, even when switching between users.

The `ENTRYPOINT` script ensures that the environment is also activated for one-off
commands when Docker is used non-interactively.

Setting `MAMBA_SKIP_ACTIVATE=1` disables both of these automatic activation methods.

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
which will bring in the git sub-modules for Bats. With the sub-modules present, `./test.sh` will run the test
suite. If GNU `parallel` is present, then the test suite will be run in parallel using all logical CPU cores
available.

### Road map

The current road map for expanding the number of base images is as follows:

1. Add all releases of debian slim that have not yet reached LTS end of life (ie, bullseye, buster, stretch)
1. Add the non-slim debian image
1. Add other debian based distributions that have community interest (such as Ubuntu)
1. Add non-debian based distributions that have community interest

The build and test infrastructure will need to be altered to support additional
base images such that automated test and build occur for all images produced.

### Policies

1. Entrypoint script should not write to files in the home directory. On some container execution systems, the host home directory is automatically mounted and we don't want to mess up or pollute the home directory on the host system.

### Parent container choice

As noted in the [micromamba documentation](https://github.com/mamba-org/mamba/blob/master/README.md#micromamba), the official micromamba binaries require glibc. Therefore Alpine Linux does not work naively. To keep the image small, a Debian slim image is used as the parent. On going efforts to generate a fully statically linked micromamba binary are documented in [mamba GitHub issue #572](https://github.com/mamba-org/mamba/issues/572), but most conda packages also depend on glibc. Therefore using a statically linked micromamba would require either a method to install glibc (or an equivalent) from a conda package or conda packages that are statically linked against glibc.
