Quick Start
===========

The ``mambaorg/micromamba`` images contain only the programs from their parent
image, the ``micromamba`` binary, ``bash``, SSL certificates, and ``glibc``.
``micromamba`` does not have a ``python`` dependency, and therefore the
``mambaorg/micromamba`` images do not contain ``python``.

The micromamba images have an empty conda environment named ``base``. Usually
you will install software into this ``base`` environment.

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

Running commands in Dockerfile within the conda environment
-----------------------------------------------------------

The conda environment is automatically activated for ``docker run ...``
commands, but it is not automatically activated during the build of an image
(``docker build ...``). In order to use a ``RUN`` command to execute a program
from a conda environment within a ``Dockerfile``, as explained in detail in the
next two subsections, you *must*:

#. Set ``ARG MAMBA_DOCKERFILE_ACTIVATE=1`` to activate the conda environment

#. Use the 'shell' form of the ``RUN`` command

Activating a conda environment for ``RUN`` commands
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

No conda environment is automatically activated during the execution
of ``RUN`` commands within a ``Dockerfile``. To have an environment active
during a ``RUN`` command, you must set ``ARG MAMBA_DOCKERFILE_ACTIVATE=1``.
For example:

   .. literalinclude:: ../examples/run_activate/Dockerfile

Use the shell form of ``RUN`` with ``micromamba``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The Dockerfile ``RUN`` command can be invoked either in the 'shell' form:

   .. code-block::

      RUN python -c "import uuid; print(uuid.uuid4())"

or the 'exec' form:

   .. code-block::

      RUN ["python", "-c", "import uuid; print(uuid.uuid4())"]  # DO NOT USE THIS FORM!

You *must* use the 'shell' form of ``RUN`` or the command will not execute in
the context of a conda environment.

Activating a conda environment for ``ENTRYPOINT`` commands
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The ``Dockerfile`` for building the ``mambaorg/micromamba`` images contains:

   .. code-block::

      ENTRYPOINT ["/usr/local/bin/_entrypoint.sh"]

where ``_entrypoint.sh`` activates the conda environment for any programs
run via ``CMD`` in a Dockerfile or using
``docker run mambaorg/micromamba my_command`` on the command line.
If you were to make an image derived from ``mambaorg/micromamba`` with:

   .. code-block::

      ENTRYPOINT ["my_command"]

then you will have removed the conda activation from the ``ENTRYPOINT`` and
``my_command`` will be executed outside of any conda environment.

If you would like an ``ENTRYPOINT`` command to be executed within an active conda
environment, then add ``"/usr/local/bin/_entrypoint.sh"`` as the first element
of the JSON array argument to ``ENTRYPOINT``. For example, if you would like
for your ``ENTRYPOINT`` command to run ``python`` from a conda environment,
then you would do:

   .. code-block::

      ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "python"]
