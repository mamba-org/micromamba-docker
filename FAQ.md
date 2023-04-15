# Frequently Asked Questions

- [Why am I getting the error "libmamba Could not solve for environment specs"?](
  #why-am-i-getting-the-error-libmamba-could-not-solve-for-environment-specs)
- [Why do I get errors when building the example `Dockerfiles`?](
  #why-do-i-get-errors-when-building-the-example-dockerfiles)
- [Why am I getting the error `critical libmamba Subprocess call failed. Aborting.`?](
  #why-am-i-getting-the-error-critical-libmamba-subprocess-call-failed-aborting)
- [How do I install software using `apt`/`apt-get`/ `apk`?](
  #how-do-I-install-software-using-apt-apt-get-apk)

## Why am I getting the error "libmamba Could not solve for environment specs"?

This indicates that `micromamba` was unable to find a set of packages which met
all the constraints that were set for the environment.

This can happen if you forgot to include a channel that is the source for a
required package.

This error sometimes occurs when moving from one CPU architecture to another,
such as when moving from x86 to a ARM-based CPUs (such as Apple M1 and M2 CPUs).
Some conda repositories do a good job of supporting multiple architectures
(such as Conda Forge), but others only support x86 CPUs (Bioconda). You can
work around this by forcing `docker build ...` to emulate another CPU
architecture by appending `--platform=linux/amd64` to the `FROM` line of your
`Dockerfile`. However, emulation can result in significantly slower builds.

## Why do I get errors when building the example `Dockerfiles`?

Docker Desktop has a configuration setting for how much disk space to use. When
this limit is reached, the error messages thrown by the container may not seem
related to disk space.  For example:

- `micromamba install ...` may give the error
  `libmamba Non-writable cache error``
- `apt-get install ...` may give the error
  `At least one invalid signature was encountered`.

To free up some of the disk space allocated to Docker, execute
`docker system prune --all`. Then attempt the `docker build ...` command again.

## Why am I getting the error `critical libmamba Subprocess call failed. Aborting.`?

`docker` had a change in how ulimit values are set within containers starting in
`docker` v22.10. By passing `docker build` or `docker run` the flag
`--ulimit nofile=65536:65536` you can increase the `nofile` limit within the
container.

## How do I install software using `apt`/`apt-get`/ `apk`?

The default user in `mambaorg/micromamba` does not have root-level permissions.
Therefore you need to switch to user `root` before installing software using
the system package manager. After installing the software you should switch
back to `$MAMBA_USER`.

Here is an example Dockerfile:

```dockerfile
FROM mambaorg/micromamba:1.4.2

COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml
RUN micromamba install -y -n base -f /tmp/env.yaml && \
    micromamba clean --all --yes

USER root
RUN apt-get update && apt-get install -y \
    bluetooth \
    && rm -rf /var/lib/apt/lists/*
USER $MAMBA_USER
```
