# micromamba_docker
Micromamba for fast building of small conda-based containers.

## Typical Usage

1. Create define your desired environment in a spec file:
```
name: base
channels:
  - conda-forge
dependencies:
  - python >=3.6,<3.7
  - ipykernel >=5.1
  - ipywidgets
```
2. Install from the spec file in your Dockerfile:
```
FROM micromamba

COPY env.yaml /root/env.yaml
RUN /bin/bash -c 'source $HOME/.bashrc \
    && micromamba install -y -f /root/env.yaml'
```
As shown above, you must source .bashrc for the `micromamba install` command to work within a Dockerfile. When actually running the micromamba image this is not required, as the /root/.bashrc is automatically sourced. The installed micromamba/conda environment will be automatically activated in the child image such that installed programs will be in your PATH.

## Parent container choice

As noted in the [micromamba documentation](https://github.com/mamba-org/mamba/blob/master/docs/source/micromamba.md#Installation), even though this image uses a staticaly linked binary, a glibc system is required. Therefore Alpine Linux does not work natively. To keep the image small, a Debian slim image is used as the parent.
