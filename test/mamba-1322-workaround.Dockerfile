FROM micromamba:test
RUN mkdir -p /opt/conda/etc/profile.d/ \
  # Define a do-nothing mamba function as a placeholder
  && echo "mamba() { __conda_activate activate base; }" > /opt/conda/etc/profile.d/mamba.sh
