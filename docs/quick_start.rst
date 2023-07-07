Quick Start
===========

The micromamba image comes with an empty environment named ``base``. Usually you
will install software into this ``base`` environment. The
``mambaorg/micromamba`` image includes any programs from its parent image, the
``micromamba`` binary, and SSL certificates. ``micromamba`` does not have a
``python`` dependency, and therefore the ``mambaorg/micromamba`` image does not
include ``python``.

#. Define your desired conda environment in a yaml file

   .. literalinclude:: ../examples/yaml_spec/env.yaml
      :language: yaml
      :caption: env.yaml

   .. warning::

      Using an environment name other than ``base`` is not recommended! If you
      must use a different environment name, then read the :ref:`documentation
      on multiple environments <multiple-environments>`.


#. Copy the yaml file into your docker image and then pass the yaml file as a
   parameter to ``micromamba`` via the ``--file`` switch

   .. literalinclude:: ../examples/yaml_spec/Dockerfile
      :language: Dockerfile
      :caption: Dockerfile

#. Build your docker image

   .. code-block::

      $ docker build --quiet --tag my_app .
      sha256:b04d00cd5e7ab14f97217c24bc89f035db33a8d339bfb9857698d9390bc66cf8

   The ``base`` conda environment is automatically activated when the image is
   running.

   .. code-block::

      $ docker run -it --rm my_app python --version
      3.9.1
