# Change Log

This change log covers changes to the docker image and does not include
[changes to the micromamba program](https://github.com/mamba-org/mamba/blob/main/CHANGELOG.md).

## 17 July 2023

- Add base image ubuntu:lunar

  uid and gid 1000 is not available in ubuntu:lunar, mambauser uid and git is
  set to 57439

- tests updated to allow for ubuntu:lunar's uid and gid values

## 15 July 2023

- Add base images for cuda version 12.2.0
- Remove base images containing Ubuntu 18.04 (bionic) as they are end of life

## 13 July 2023

- Updated to micromamba version 1.4.9

## 11 July 2023

- Updated to micromamba version 1.4.8

## 8 July 2023

- Documentation converted to rst format, hosted on readthedocs.io

## 6 July 2023

- Update to micromamba version 1.4.7

## 1 July 2023

- Update to micromamba version 1.4.6

## 29 Jun 2023

- Update to micromamba version 1.4.5

## 20 June 2023

- Add Debian Bookworm base images

## 15 June 2023

- Update to micromamba version 1.4.4

## 23 May 2023

- bump requests python package from 2.26.0 to 2.31.0

## 16 May 2023

- Update to micromamba version 1.4.3

## 15 May 2023

- Revert broken add of ubuntu:lunar base image

## 13 May 2023

- Add ubuntu:lunar base image

## 10 May 2023

- Add base images for cuda 12.1.1

## 7 April 2023

- Update to micromamba version 1.4.2

## 28 March 2023

- Update to micromamba version 1.4.1

## 23 March 2023

- Update to micromamba version 1.4.0

## 14 March 2023

- Also push images to GitHub Container Registry

## 10 March 2023

- Add base images for cuda 12.1.0

## 21 Febuary 2023

- In `.gitattributes` fix line endings for `*.sh` files to allow building on Windows

## 19 Febuary 2023

- Start FAQ

## 9 Febuary 2023

- update `add_micromamba` example to include `USER root` before copying files in

## 3 Febuary 2023

- added support for alpine base image
- bump CUDA 12 to 12.0.1

## 17 January 2023

- added base image `ubuntu:kinetic`
- added base image `nvidia/cuda:12.0.0-base-ubuntu22.04`
- added base image `nvidia/cuda:12.0.0-base-ubuntu20.04`

## 8 September 2022

- Automatically perform shell initialization for `conda` and `mamba` if they
  are installed
- Drop the base image `debian:buster` and `debian:buster-slim` as they are no
  longer under offical debian support
- Install shell hooks for `micromamba`, `conda`, and `mamba` even if
  `MAMBA_SKIP_ACTIVATE=1`

## 7 July 2022

- Moved code from `Dockerfile` to separate bash scripts
  `_dockerfile_initialize_user_accounts.sh` and
  `_dockerfile_setup_root_prefix.sh`

## 6 July 2022

- Add images based on nvidia/cuda:\*-base-ubuntu\*

## 5 June 2022

- Build images from all Debian releases that have not yet reached end of life
- Build images from both slim and non-slim Debian images
- Revamp tagging to support multiple base images

## 13 January 2022

- Change the default username from `micromamba` to `mambauser`.
- Add the environment variable `MAMBA_USER` to store the value of the default
  username.

## 15 December 2021

- If environmental variable `MAMBA_SKIP_ACTIVATE` is set to `1`, then no conda
  environment will be automatically activated during a `docker run ...` command.

## 14 December 2021

- Images are now built on every push to `main` branch or when cronjob sees
  that conda-forge has a newer version of micromamba that does not yet have
  a corresponding image on dockerhub
- Images will now also be tagged with a the short version of the git SHA
  hash from this git repository.
- The outputs of `check_version.py` have been modified to make the build
  scripts better

## 13 December 2021

- Consolidated activation code into `/usr/local/bin/_activate_current_env.sh`
- Moved `_entrypoint.sh` and `_docker_shell.sh` into `/usr/local/bin`

## 8 December 2021

- Stop adding `MAMBA_ROOT_PREFIX/bin` in `PATH`.
- Remove tests that override entrypoint. Users should not expect their conda
  env to get activated if they interfere with the entrypoint script.
- Remove test of using `RUN` command with 'exec' form to access conda
  installed software. This required the `PATH` modification that is being
  removed. Use 'shell' form of `RUN` command instead.
- Remove call to `micromamba` that adds shell completion commands from
  `.bashrc`, as this is now included in the shell hooks command.

## 4 December 2021

- Activation of conda env during docker build is now triggered by
  `ARG MAMBA_DOCKERFILE_ACTIVATE=1`
- Entrypoint script moved to `/bin/_entrypoint.sh`
- `SHELL`now set to `/bin/_dockerfile_shell.sh`, which activates an
  environment within the docker build if  `MAMBA_DOCKERFILE_ACTIVATE=1`
  and then executes any arguments using `/bin/bash`

## 30 November 2021

- Move setup of bash environment from entrypoint to .bashrc
- Modifications to .bashrc are done during image build

## 5 November 2021

- Entrypoint evaluates the micromamba shell hook directly
- Entrypoint no longer writes to ~/.bashrc

## 18 September 2021

- base image changed from debian:buster-slim to debian:bullseye-slim
- added tests to check that example Dockerfiles build

## 6 September 2021

- add build for pcc64le

## 30 June 2021

- default user changed from root to micromamba
