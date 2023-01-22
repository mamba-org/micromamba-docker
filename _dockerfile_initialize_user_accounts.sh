#!/bin/bash

set -euf -o pipefail

echo "source /usr/local/bin/_activate_current_env.sh" >> ~/.bashrc

if grep -q '^ID=alpine$' /etc/os-release; then
  echo "source /usr/local/bin/_activate_current_env.sh" >> /etc/profile.d/micromamba_activate.sh
  chmod a+x /etc/profile.d/micromamba_activate.sh

  if [ ! "$(id -g "${MAMBA_USER}" 2> /dev/null)" == "${MAMBA_USER_GID}" ]; then
    addgroup -g "${MAMBA_USER_GID}" "${MAMBA_USER}"
  fi

  if [ ! "$(id -u "${MAMBA_USER}" 2> /dev/null)" == "${MAMBA_USER_ID}" ]; then
    adduser "${MAMBA_USER}" -G "${MAMBA_USER}" \
	    -s /bin/bash -u "${MAMBA_USER_ID}" -D
  fi
else  # debian
  echo "source /usr/local/bin/_activate_current_env.sh" >> /etc/skel/.bashrc

  if [ ! "$(id -g "${MAMBA_USER}" 2> /dev/null)" == "${MAMBA_USER_GID}" ]; then
    groupadd -g "${MAMBA_USER_GID}" "${MAMBA_USER}"
  fi

  if [ ! "$(id -u "${MAMBA_USER}" 2> /dev/null)" == "${MAMBA_USER_ID}" ]; then
    useradd -u "${MAMBA_USER_ID}" -g "${MAMBA_USER_GID}" -ms /bin/bash "${MAMBA_USER}"
  fi
fi

echo "${MAMBA_USER}" > "/etc/arg_mamba_user"
chmod -R a+rwx "/home" "/etc/arg_mamba_user"
