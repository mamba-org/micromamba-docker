5 June 2022
========================

- Build images from all Debian releases that have not yet reached end of life
- Build images from both slim and non-slim Debian images
- Revamp tagging to support multiple base images

13 January 2022
========================

- Change the default username from `micromamba` to `mambauser`.
- Add the environment variable `MAMBA_USER` to store the value of the default username.

15 December 2021
========================

- If environmental variable `MAMBA_SKIP_ACTIVATE` is set to `1`, then no conda environment will be automatically activated during a `docker run ...` command.

14 December 2021
========================

- Images are now built on every push to `main` branch or when cronjob sees that conda-forge has a newer version of micromamba that does not yet have a corresponding image on dockerhub
- Images will now also be tagged with a the short version of the git SHA hash from this git repository.
- The outputs of `check_version.py` have been modified to make the build scripts better

13 December 2021
========================

- Consolidated activation code into `/usr/local/bin/_activate_current_env.sh`
- Moved `_entrypoint.sh` and `_docker_shell.sh` into `/usr/local/bin`

8 December 2021
========================

- Stop adding `MAMBA_ROOT_PREFIX/bin` in `PATH`.
- Remove tests that override entrypoint. Users should not expect their conda env to get activated if they interfere with the entrypoint script.
- Remove test of using `RUN` command with 'exec' form to access conda installed software. This required the `PATH` modification that is being removed. Use 'shell' form of `RUN` command instead.
- Remove call to `micromamba` that adds shell completion commands from `.bashrc`, as this is now included in the shell hooks command.

4 December 2021
========================

- Activation of conda env during docker build is now triggered by `ARG MAMBA_DOCKERFILE_ACTIVATE=1`
- Entrypoint script moved to `/bin/_entrypoint.sh`
- `SHELL`now set to `/bin/_dockerfile_shell.sh`, which activates an environment within the docker build if  `MAMBA_DOCKERFILE_ACTIVATE=1` and then executes any arguments using `/bin/bash`

30 November 2021
========================

- Move setup of bash environment from entrypoint to .bashrc
- Modifications to .bashrc are done during image build

5 November 2021
========================

- Entrypoint evaluates the micromamba shell hook directly
- Entrypoint no longer writes to ~/.bashrc

18 September 2021
========================

- base image changed from debian:buster-slim to debian:bullseye-slim
- added tests to check that example Dockerfiles build

6 September 2021
========================

- add build for pcc64le

30 June 2021
========================

- default user changed from root to micromamba
