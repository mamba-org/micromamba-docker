#!/bin/bash

set -euf -o pipefail

echo 'source /usr/local/bin/_activate_current_env.sh' >> /root/.bashrc

mkdir -p /etc/skel
echo 'source /usr/local/bin/_activate_current_env.sh' >> /etc/skel/.bashrc

if grep -q '^ID=alpine$' /etc/os-release; then
  group_cmd=('addgroup')
  user_cmd=('adduser' '-D' '-G' "${MAMBA_USER}")
else  # debian and redhat-based
  group_cmd=('groupadd')
  user_cmd=('useradd' '-m' '-g' "${MAMBA_USER_GID}")
fi

if [ ! "$(id -g "${MAMBA_USER}" 2> /dev/null)" == "${MAMBA_USER_GID}" ]; then
  "${group_cmd[@]}" -g "${MAMBA_USER_GID}" "${MAMBA_USER}"
fi
if [ ! "$(id -u "${MAMBA_USER}" 2> /dev/null)" == "${MAMBA_USER_ID}" ]; then
  "${user_cmd[@]}" -s /bin/bash -u "${MAMBA_USER_ID}" "${MAMBA_USER}"
fi

echo "${MAMBA_USER}" > '/etc/arg_mamba_user'
chmod -R a+rwx '/home' '/etc/arg_mamba_user'
