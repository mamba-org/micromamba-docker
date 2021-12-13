FROM micromamba:test
RUN mkdir -p /opt/conda/etc/profile.d/ \
  # Define a do-nothing mamba function as a placeholder
  && echo "mamba() { :; }" > /opt/conda/etc/profile.d/mamba.sh
