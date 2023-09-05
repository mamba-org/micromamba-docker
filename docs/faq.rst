.. _frequently-asked-questions-label:

Frequently Asked Questions
--------------------------

Why am I getting the error ``libmamba Could not solve for environment specs``?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This indicates that ``micromamba`` was unable to find a set of packages which met
all the constraints that were set for the environment.

This can happen if you forgot to include a channel that is the source for a
required package.

This error sometimes occurs when moving from one CPU architecture to another,
such as when moving from x86 to a ARM-based CPUs (such as Apple M1 and M2 CPUs).
Some conda repositories do a good job of supporting multiple architectures
(such as Conda Forge), but others only support x86 CPUs (Bioconda). You can
work around this by forcing ``docker build ...`` to emulate another CPU
architecture by appending ``--platform=linux/amd64`` to the ``FROM`` line of your
``Dockerfile``. However, emulation can result in significantly slower builds.

Why do I get errors when building the example ``Dockerfiles``?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Docker Desktop has a configuration setting for how much disk space to use. When
this limit is reached, the error messages thrown by the container may not seem
related to disk space. For example:

* ``micromamba install ...`` may give the error
  ``libmamba Non-writable cache error````
* ``apt-get install ...`` may give the error
  ``At least one invalid signature was encountered``.

To free up some of the disk space allocated to Docker, execute
``docker system prune --all``. Then attempt the ``docker build ...`` command again.

Why am I getting the error ``critical libmamba Subprocess call failed. Aborting.``?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

``docker`` had a change in how ulimit values are set within containers starting in
``docker`` v22.10. By passing ``docker build`` or ``docker run`` the flag
``--ulimit nofile=65536:65536`` you can increase the ``nofile`` limit within the
container.

How do I install software using ``apt``/``apt-get``/``apk``?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

The default user in ``mambaorg/micromamba`` does not have root-level permissions.
Therefore you need to switch to user ``root`` before installing software using
the system package manager. After installing the software you should switch
back to ``$MAMBA_USER``:

.. literalinclude:: ../examples/apt_install/Dockerfile
   :language: Dockerfile
   :caption: Dockerfile

How can I stop ``micromamba`` from hanging when emulating a different CPU architecture?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

A bug in QEMU can cause ``micromamba install ...`` to hang when emulating a
different CPU. In particular, this has been observed when emulating x86 on
ARM-based CPUs (such as Apple M1 and M2 CPUs). To work around this, you can
configure ``micromamba`` to use only one thread for extracting packages:

.. code-block:: console

   micromamba config set extract_threads 1 \
   && micromamba install ...

For more information see issue
`#349 <https://github.com/mamba-org/micromamba-docker/issues/349>`_,

How can I use a ``mambaorg/micromamba`` based image in a GitHub Action?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

GitHub Actions override the two methods our images use to automatically
activate environments. First, the ``ENTRYPOINT`` script is disabled and second,
the ``~/.bashrc`` file is not sourced becuase the location of the home
directory is modified.

To enable automatic activation of environments, you can use the
``_entrypoint.sh`` script as the ``shell`` command in your GitHub Action.

.. code-block::

   jobs:
     my_job:
       runs-on: ubuntu-latest
       container:
         image: mambaorg/micromamba:latest
         options: --user=root
       steps:
       - uses: actions/checkout@master
       - shell: _entrypoint.sh /bin/bash --noprofile --norc -eo pipefail {0}
         run: |
           micromamba info
           which micromamba

If you are using the ``actions/checkout`` action, you will need to add the
``--user=root`` option to the ``container`` section of your GitHub Action.
This is because the ``actions/checkout`` action creates a directory in the
container that is owned by ``root``.

How can I use a ``mambaorg/micromamba`` based image with ``apptainer``?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

There are three ``apptainer``/``singularity`` sub-commands that can be used to
execute a container:

#. ``apptainer run`` will execute the entrypoint script and automatically
   activate the ``base`` environment.

#. ``apptainer exec`` does not execute the entrypoint script and therefore
   does not automatically activate the ``base`` environment. By prepending
   ``/usr/local/bin/_entrypoint.sh`` to the command you want to execute within
   the container, you can activate the ``base`` environment. For example:

   .. code-block:: console

      apptainer exec /usr/local/bin/_entrypoint.sh micromamba info

#. ``apptainer shell`` does not execute the entrypoint script and therefore
   does not automatically activate the ``base`` environment. By supplying the
   ``--shell /usr/local/bin/_apptainer_shell.sh`` option to ``apptainer exec``,
   you can activate the ``base`` environment. This option can alternatively be
   supplied via the ``APPTAINER_SHELL`` environment variable.
