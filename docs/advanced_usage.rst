Advanced Usages
===============

Pass list of packages to install within a Dockerfile RUN command
----------------------------------------------------------------

.. code-block:: Dockerfile
   :caption: Dockerfile

   FROM mambaorg/micromamba:1.4.4
   RUN micromamba install --yes --name base --channel conda-forge \
         pyopenssl=20.0.1  \
         python=3.9.1 \
         requests=2.25.1 && \
       micromamba clean --all --yes

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

.. code-block:: Dockerfile
   :caption: Dockerfile

   FROM mambaorg/micromamba:1.4.4
   COPY --chown=$MAMBA_USER:$MAMBA_USER env1.yaml /tmp/env1.yaml
   COPY --chown=$MAMBA_USER:$MAMBA_USER env2.yaml /tmp/env2.yaml
   RUN micromamba create --yes --file /tmp/env1.yaml && \
       micromamba create --yes --file /tmp/env2.yaml && \
       micromamba clean --all --yes

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

   .. code-block:: Dockerfile
      :caption: Dockerfile

      FROM mambaorg/micromamba:1.4.4
      ARG NEW_MAMBA_USER=new-username
      ARG NEW_MAMBA_USER_ID=1000
      ARG NEW_MAMBA_USER_GID=1000
      USER root
      RUN usermod "--login=${NEW_MAMBA_USER}" "--home=/home/${NEW_MAMBA_USER}" \
              --move-home "-u ${NEW_MAMBA_USER_ID}" "${MAMBA_USER}" && \
          groupmod "--new-name=${NEW_MAMBA_USER}" \
                   "-g ${NEW_MAMBA_USER_GID}" "${MAMBA_USER}" && \
          # Update the expected value of MAMBA_USER for the
          # _entrypoint.sh consistency check.
          echo "${NEW_MAMBA_USER}" > "/etc/arg_mamba_user" && \
          :
      ENV MAMBA_USER=$NEW_MAMBA_USER
      USER $MAMBA_USER

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

.. code-block:: Dockerfile
   :caption: Dockerfile

   # bring in the micromamba image so we can copy files from it
   FROM mambaorg/micromamba:1.4.4 as micromamba

   # This is the image we are going add micromaba to:
   FROM tomcat:9-jdk17-temurin-focal

   USER root

   # if your image defaults to a non-root user, then you may want to make the
   # next 3 ARG commands match the values in your image. You can get the values
   # by running: docker run --rm -it my/image id -a
   ARG MAMBA_USER=mamba
   ARG MAMBA_USER_ID=1000
   ARG MAMBA_USER_GID=1000
   ENV MAMBA_USER=$MAMBA_USER
   ENV MAMBA_ROOT_PREFIX="/opt/conda"
   ENV MAMBA_EXE="/bin/micromamba"

   COPY --from=micromamba "$MAMBA_EXE" "$MAMBA_EXE"
   COPY --from=micromamba /usr/local/bin/_activate_current_env.sh /usr/local/bin/_activate_current_env.sh
   COPY --from=micromamba /usr/local/bin/_dockerfile_shell.sh /usr/local/bin/_dockerfile_shell.sh
   COPY --from=micromamba /usr/local/bin/_entrypoint.sh /usr/local/bin/_entrypoint.sh
   COPY --from=micromamba /usr/local/bin/_activate_current_env.sh /usr/local/bin/_activate_current_env.sh
   COPY --from=micromamba /usr/local/bin/_dockerfile_initialize_user_accounts.sh /usr/local/bin/_dockerfile_initialize_user_accounts.sh
   COPY --from=micromamba /usr/local/bin/_dockerfile_setup_root_prefix.sh /usr/local/bin/_dockerfile_setup_root_prefix.sh

   RUN /usr/local/bin/_dockerfile_initialize_user_accounts.sh && \
       /usr/local/bin/_dockerfile_setup_root_prefix.sh

   USER $MAMBA_USER

   SHELL ["/usr/local/bin/_dockerfile_shell.sh"]

   ENTRYPOINT ["/usr/local/bin/_entrypoint.sh"]
   # Optional: if you want to customize the ENTRYPOINT and have a conda
   # environment activated, then do this:
   # ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "my_entrypoint_program"]

   # You can modify the CMD statement as needed....
   CMD ["/bin/bash"]

   # Optional: you can now populate a conda environment:
   RUN micromamba install --yes --name base --channel conda-forge \
         jq && \
        micromamba clean --all --yes

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
