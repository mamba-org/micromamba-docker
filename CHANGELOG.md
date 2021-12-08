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
