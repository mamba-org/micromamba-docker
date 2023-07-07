Advanced Usages
===============

Pass list of packages to install within a Dockerfile RUN command
----------------------------------------------------------------

.. literalinclude:: ../examples/cmdline_spec/Dockerfile
   :language: Dockerfile
   :caption: Dockerfile

Using a lockfile
----------------

Pinning a package to a version string doesn't guarantee the exact same
package file is retrieved each time.  A lockfile utilizes package hashes
to ensure package selection is reproducible. A lockfile can be generated
using `conda-lock <https://github.com/conda-incubator/conda-lock>`_ or
``micromamba``:

.. code-block:: bash

   docker run -it --rm -v $(pwd):/tmp mambaorg/micromamba:1.4.4 \
      /bin/bash -c "micromamba create --yes --name new_env --file env.yaml && \
                    micromamba env export --name new_env --explicit > env.lock"

The lockfile can then be used to install into the pre-existing ``base`` conda
environment:

.. code-block:: Dockerfile
   :caption: Dockerfile

   FROM mambaorg/micromamba:1.4.4
   COPY --chown=$MAMBA_USER:$MAMBA_USER env.lock /tmp/env.lock
   RUN micromamba install --name base --yes --file /tmp/env.lock \
       && micromamba clean --all --yes

Or the lockfile can be used to create and populate a new conda environment:

.. code-block:: Dockerfile
   :caption: Dockerfile

   FROM mambaorg/micromamba:1.4.4
   COPY --chown=$MAMBA_USER:$MAMBA_USER env.lock /tmp/env.lock
   RUN micromamba create --name my_env_name --yes --file /tmp/env.lock \
       && micromamba clean --all --yes

When a lockfile is used to create an environment, the ``micromamba create ...``
command does not query the package channels or execute the solver. Therefore
using a lockfile has the added benefit of reducing the time to create a conda
environment.

.. _multiple-environments:

Multiple environments
---------------------

For most use cases you will only want a single conda environment within your
derived image, but you can create multiple conda environments:

.. literalinclude:: ../examples/multi_env/Dockerfile
   :language: Dockerfile
   :caption: Dockerfile

You can then set the active environment by passing the ``ENV_NAME``
environment variable like:

.. code-block:: bash

   docker run -e ENV_NAME=env2 my_multi_conda_image

Changing the user id or name
----------------------------

The default username is stored in the environment variable ``MAMBA_USER``, and
is currently ``mambauser``. (Before 2022-01-13 it was ``micromamba``, and before
2021-06-30 it was ``root``.) Micromamba-docker can be run with any UID/GID by
passing the ``docker run ...`` command the ``--user=UID:GID`` parameters.
Running with ``--user=root`` is supported.

There are two supported methods for changing the default username to something
other than ``mambauser``:

#. If rebuilding this image from scratch, the default username ``mambauser``
   can be adjusted by passing ``--build-arg MAMBA_USER=new-username`` to the
   ``docker build`` command. User id and group id can be adjusted similarly by
   passing ``--build-arg MAMBA_USER_ID=new-id --build-arg MAMBA_USER_GID=new-gid``

#. When building an image ``FROM`` an existing micromamba image,

   .. literalinclude:: ../examples/modify_username/Dockerfile
      :language: Dockerfile
      :caption: Dockerfile

Disabling automatic activation
------------------------------

It is assumed that users will want their environment automatically activated
whenever running this container. This behavior can be disabled by setting
the environment variable ``MAMBA_SKIP_ACTIVATE=1``.

For example, to open an interactive bash shell without activating the
environment:

.. code-block:: bash

   docker run --rm -it -e MAMBA_SKIP_ACTIVATE=1 mambaorg/micromamba bash

Details about automatic activation
----------------------------------

At container runtime, activation occurs by default at two possible points:

1. The end of the ``~/.bashrc`` file, which is loaded by interactive non-login
   Bash shells.

1. The ``ENTRYPOINT`` script, which is automatically prepended to ``docker run``
   commands.

The activation in ``~/.bashrc`` ensures that the environment is activated in
interactive terminal sessions, even when switching between users.

The ``ENTRYPOINT`` script ensures that the environment is also activated for
one-off commands when Docker is used non-interactively.

Setting ``MAMBA_SKIP_ACTIVATE=1`` disables both of these automatic activation
methods.

Adding micromamba to an existing Docker image
---------------------------------------------

Adding micromamba functionality to an existing Docker image can be accomplished
like this:

.. literalinclude:: ../examples/add_micromamba/Dockerfile
   :language: Dockerfile
   :caption: Dockerfile

On ``docker exec ...``
----------------------

Your experience using ``docker exec ...`` may not match your expectations for
automatic environment activation (
`#128 <https://github.com/mamba-org/micromamba-docker/issues/128>`_,
`#233 <https://github.com/mamba-org/micromamba-docker/issues/233>`_)
``docker exec ... <command>`` executes ``<command>`` directly, without an
entrypoint or login/interactive shell. There is no known way to automatically
(and correctly) trigger conda environment activation for a command run through
``docker exec ...``.

The *recommended* method to explicitly activate your environment when using
``docker exec ...`` is:

.. code-block:: bash

   docker exec <container> micromamba run -n <environment_name> <command>

If you want to use the base environment, you can omit ``-n <environment_name>``.

An alternative method to trigger activation is to explicitly run your command
within an interactive ``bash`` shell with ``-i``:

.. code-block:: bash

   docker exec <container> bash -i -c "<command>"

Finally, you can modify the ``PATH`` at build-time to approximate an activated
environment during ``docker exec``:

.. code-block:: Dockerfile
   :caption: Dockerfile

   ENV PATH "$MAMBA_ROOT_PREFIX/bin:$PATH"  # Not a preferred method!

.. warning::

   Modifying ``PATH``  will not work in all cases, such as multiple conda
   environments within a single image.

Use of the ``SHELL`` command within a Dockerfile
------------------------------------------------

The ``mambaorg/micromaba`` Dockerfile makes use of the ``SHELL`` command:

.. code-block:: Dockerfile
   :caption: Dockerfile

   SHELL ["/usr/local/bin/_dockerfile_shell.sh"]

.. warning::

   If a derived image overrides this ``SHELL`` configuration, then some of
   the automatic conda environment activation functionality will break.
