#!/bin/bash

set -euf -o pipefail

echo "source /usr/local/bin/_activate_current_env.sh" >> ~/.bashrc
echo "source /usr/local/bin/_activate_current_env.sh" >> /etc/skel/.bashrc

if [ ! "$(id -g "${MAMBA_USER}" 2> /dev/null)" == "${MAMBA_USER_GID}" ]; then
  groupadd -g "${MAMBA_USER_GID}" "${MAMBA_USER}"
fi

if [ ! "$(id -u "${MAMBA_USER}" 2> /dev/null)" == "${MAMBA_USER_ID}" ]; then
  useradd -u "${MAMBA_USER_ID}" -g "${MAMBA_USER_GID}" -ms /bin/bash "${MAMBA_USER}"
fi

echo "${MAMBA_USER}" > "/etc/arg_mamba_user"
chmod -R a+rwx "/home" "/etc/arg_mamba_user"
