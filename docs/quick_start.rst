Quick Start
===========

The micromamba image comes with an empty environment named ``base``. Usually you
will install software into this ``base`` environment. The
``mambaorg/micromamba`` image includes any programs from its parent image, the
``micromamba`` binary, and SSL certificates. ``micromamba`` does not have a
``python`` dependency, and therefore the ``mambaorg/micromamba`` image does not
include ``python``.

#. Define your desired conda environment in a yaml file

   .. code-block:: yaml
      :caption: env.yaml

      name: base
      channels:
        - conda-forge
      dependencies:
        - pyopenssl=20.0.1
        - python=3.9.1
        - requests=2.25.1

   .. warning::

      Using an environment name other than ``base`` is not recommended! If you
      must use a different environment name, then read the :ref:`documentation
      on multiple environments <multiple-environments>`.


#. Copy the yaml file into your docker image and then pass the yaml file as a
   parameter to ``micromamba`` via the ``--file`` switch

   .. code-block:: Dockerfile
      :caption: Dockerfile

      FROM mambaorg/micromamba:1.4.4
      COPY --chown=$MAMBA_USER:$MAMBA_USER env.yaml /tmp/env.yaml
      RUN micromamba install --yes --name base --file /tmp/env.yaml && \
          micromamba clean --all --yes

#. Build your docker image

   .. code-block::

      $ docker build --quiet --tag my_app .
      sha256:b04d00cd5e7ab14f97217c24bc89f035db33a8d339bfb9857698d9390bc66cf8

   The ``base`` conda environment is automatically activated when the image is
   running.

   .. code-block::

      $ docker run -it --rm my_app python --version
      3.9.1
