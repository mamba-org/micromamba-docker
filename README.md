# micromamba-docker

[Micromamba](https://github.com/mamba-org/mamba#micromamba) for fast building of small [conda](https://docs.conda.io/)-based containers.

Images available on Dockerhub at [mambaorg/micromamba](https://hub.docker.com/r/mambaorg/micromamba). Source code on GitHub at [mamba-org/micromamba-docker](https://github.com/mamba-org/micromamba-docker/).

"This is amazing. I switched CI for my projects to micromamba, and compared to using a miniconda docker image, this reduced build times more than 2x" -- A new micromamba-docker user

## Tags

The set of tags includes permutations of:
 - full or partial version numbers corresponding to the `micromamba` version within the image
 - git commit hashes (`git-<HASH>`, where `<HASH>` is the first 7 characters of the git commit hash in [mamba-org/micromamba-docker](https://github.com/mamba-org/micromamba-docker/))
 - base image name (Debian or Ubuntu code name, such as `bullseye`, plus `-slim` if derived from a Debian `slim` image)
   - For CUDA base images, this porition of the tag is set to`<ubuntu_code_name>-cuda-<cuda_version>`

The tag `latest` is based on the `slim` image of the most recent Debian release, currently `bullseye-slim`.

Tags that do not contain `git` are rolling tags, meaning these tags get reassigned to new images each time these images are built. 

To reproducibly build images derived from these `micromamba` images, the best practice is for the Dockerfile `FROM`
command to reference the image's sha256 digest and not use tags.

## Supported shells

We have been focused on supporting use of the `bash` shell. Support for
additional shells is on our [road map](#road-map).

## Quick start

The micromamba image comes with an empty environment named 'base'. Usually you
will install software into this 'base' environment.

1. Define your desired conda environment in a yaml file:

    ```yaml
    # Using an environment name other than "base" is not recommended!
    # Read https://github.com/mamba-org/micromamba-docker#multiple-environments
    # if you must use a different environment name.
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
    FROM mambaorg/micromamba:0.24.0
    COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml
    RUN micromamba install -y -n base -f /tmp/env.yaml && \
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
FROM mambaorg/micromamba:0.24.0
COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml
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
FROM mambaorg/micromamba:0.24.0
RUN micromamba install --yes --name base --channel conda-forge \
      pyopenssl=20.0.1  \
      python=3.9.1 \
      requests=2.25.1 && \
    micromamba clean --all --yes
```

### Using a lockfile

Pinning a package to a version string doesn't guarantee the exact same
package file is retrieved each time.  A lockfile utilizes package hashes
to ensure package selection is reproducible. A lockfile can be generated
using [conda-lock](https://github.com/conda-incubator/conda-lock) or
micromamba:

```bash
docker run -it --rm -v $(pwd):/tmp mambaorg/micromamba:0.24.0 \
   /bin/bash -c "micromamba create --yes --name new_env --file env.yaml && \
                 micromamba env export --name new_env --explicit > env.lock"
```

The lockfile can then be used to install into the pre-existing `base` conda environment:

```Dockerfile
FROM mambaorg/micromamba:0.24.0
COPY --chown=$MAMBA_USER:$MAMBA_USER env.lock /tmp/env.lock
RUN micromamba install --name base --yes --file /tmp/env.lock && \
    micromamba clean --all --yes
```

Or the lockfile can be used to create and populate a new conda environment:

```Dockerfile
FROM mambaorg/micromamba:0.24.0
COPY --chown=$MAMBA_USER:$MAMBA_USER env.lock /tmp/env.lock
RUN micromamba create --name my_env_name --yes --file /tmp/env.lock && \
    micromamba clean --all --yes
```

When a lockfile is used to create an environment, the `micromamba create ..`
command does not query the package channels or execute the solver. Therefore
using a lockfile has the added benefit of reducing the time to create a conda
environment.

### Multiple environments

For most use cases you will only want a single conda environment within your
derived image, but you can create multiple conda environments:

```Dockerfile
FROM mambaorg/micromamba:0.24.0
COPY --chown=$MAMBA_USER:$MAMBA_USER env1.yaml /tmp/env1.yaml
COPY --chown=$MAMBA_USER:$MAMBA_USER env2.yaml /tmp/env2.yaml
RUN micromamba create --yes --file /tmp/env1.yaml && \
    micromamba create --yes --file /tmp/env2.yaml && \
    micromamba clean --all --yes
```

You can then set the active environment by passing the `ENV_NAME` environment variable like:

```bash
docker run -e ENV_NAME=env2 my_multi_conda_image
```

### Changing the user id or name

The default username is stored in the environment variable `MAMBA_USER`, and is currently `mambauser`. (Before 2022-01-13 it was `micromamba`, and before 2021-06-30 it was `root`.) Micromamba-docker can be run with any UID/GID by passing the `docker run ...` command the `--user=UID:GID` parameters. Running with `--user=root` is supported.

There are two supported methods for changing the default username to something other than `mambauser`:

1. If rebuilding this image from scratch, the default username `mambauser` can be adjusted by passing `--build-arg MAMBA_USER=new-username` to the `docker build` command. User id and group id can be adjusted similarly by passing `--build-arg MAMBA_USER_ID=new-id --build-arg MAMBA_USER_GID=new-gid`

2. When building an image `FROM` an existing micromamba image,

    ```Dockerfile
    FROM mambaorg/micromamba:0.24.0
    ARG NEW_MAMBA_USER=new-username
    ARG NEW_MAMBA_USER_ID=1000
    ARG NEW_MAMBA_USER_GID=1000
    USER root
    RUN usermod "--login=${NEW_MAMBA_USER}" "--home=/home/${NEW_MAMBA_USER}" \
            --move-home "-u ${NEW_MAMBA_USER_ID}" "${MAMBA_USER}" && \
        groupmod "--new-name=${NEW_MAMBA_USER}" "-g ${NEW_MAMBA_USER_GID}" "${MAMBA_USER}" && \
        # Update the expected value of MAMBA_USER for the _entrypoint.sh consistency check.
        echo "${NEW_MAMBA_USER}" > "/etc/arg_mamba_user" && \
        :
    ENV MAMBA_USER=$NEW_MAMBA_USER
    USER $MAMBA_USER
    ```

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

### Adding micromamba to an existing Docker image

Adding micromamba functionality to an existing Docker image can be accomplished like this:

```Dockerfile
# bring in the micromamba image so we can copy files from it
FROM mambaorg/micromamba:0.24.0 as micromamba

# This is the image we are going add micromaba to: 
FROM tomcat:9-jdk17-temurin-focal

ARG MAMBA_USER=mamba
ARG MAMBA_USER_ID=1000
ARG MAMBA_USER_GID=1000
ENV MAMBA_USER=$MAMBA_USER
ENV MAMBA_ROOT_PREFIX="/opt/conda"
ENV MAMBA_EXE="/bin/micromamba"

COPY --from=micromamba "$MAMBA_EXE" "$MAMBA_EXE"
COPY --from=micromamba /usr/local/bin/_activate_current_env.sh /usr/local/bin/_activate_current_env.sh
COPY --from=micromamba /usr/local/bin/_dockerfile_shell.sh /usr/local/bin/_dockerfile_shell.sh
COPY --from=micromamba /usr/local/bin/_entrypoint.sh /usr/local/bin/_entrypoint.sh
COPY --from=micromamba /usr/local/bin/_activate_current_env.sh /usr/local/bin/_activate_current_env.sh
COPY --from=micromamba /usr/local/bin/_dockerfile_initialize_user_accounts.sh /usr/local/bin/_dockerfile_initialize_user_accounts.sh
COPY --from=micromamba /usr/local/bin/_dockerfile_setup_root_prefix.sh /usr/local/bin/_dockerfile_setup_root_prefix.sh

RUN /usr/local/bin/_dockerfile_initialize_user_accounts.sh && \
    /usr/local/bin/_dockerfile_setup_root_prefix.sh

USER $MAMBA_USER

SHELL ["/usr/local/bin/_dockerfile_shell.sh"]

ENTRYPOINT ["/usr/local/bin/_entrypoint.sh"]
# Optional: if you want to customize the ENTRYPOINT and have a conda
# environment activated, then do this:
# ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "my_entrypoint_program"]

# You can modify the CMD statement as needed....
CMD ["/bin/bash"]

# Optional: you can now populate a conda environment:
RUN micromamba install --yes --name base --channel conda-forge \
      jq && \
    micromamba clean --all --yes
```

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
which will bring in the git sub-modules for Bats. [Nox](https://nox.thea.codes/) is used to
automate tests and must be installed separately. To execute the test suite on all base
images, run `nox` in the top-level directory of the repo. To execute the test suite on a single
base image, run `nox --session "tests(base_image='debian:bullseye-slim')"`. If GNU `parallel`
is available on the `$PATH`, then the test suite will be run in parallel using all logical CPU cores
available.

### Road map

The current road map for expanding the number of base images and supported shells is as follows:

1. Add non-Debian based distributions that have community interest
1. Add support for non-`bash` shells based on community interest

The build and test infrastructure will need to be altered to support additional
base images such that automated test and build occur for all images produced.

### Policies

1. Entrypoint script should not write to files in the home directory. On some container execution systems, the host home directory is automatically mounted and we don't want to mess up or pollute the home directory on the host system.

### Parent container choice

As noted in the [micromamba documentation](https://github.com/mamba-org/mamba/blob/master/README.md#micromamba), the official micromamba binaries require glibc. Therefore Alpine Linux does not work naively. To keep the image small, a Debian slim image is used as the default parent image. On going efforts to generate a fully statically linked micromamba binary are documented in [mamba GitHub issue #572](https://github.com/mamba-org/mamba/issues/572), but most conda packages also depend on glibc. Therefore using a statically linked micromamba would require either a method to install glibc (or an equivalent) from a conda package or conda packages that are statically linked against glibc.
