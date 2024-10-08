Development
===========

Branches
--------

Code contributions should start on a feature branch derived from the ``dev``
branch. Pull requests will then be merged into the ``dev`` branch. When a new
major or minor version of ``micromamba`` is released, then the ``dev`` branch
will be updated to build the new version and ``dev`` will be be merged into
the ``main`` branch. This ensures that the image behavior remains constant
for each minor version of ``micromamba``.

The following types of changes are allowed to bypass the ``dev`` branch
and have their pull requests go straight to the ``main`` branch:

* bumping versions of existing base images
* removing a base image that is no longer supported
* documentation enhancements
* testing changes
* security updates

While documentation enhancements can bypass the ``dev`` branch,
documentation for new features should be committed to ``dev`` along with the
code for the feature.

Testing
-------

Testing Dependencies
^^^^^^^^^^^^^^^^^^^^

* ``docker``
* ``nox``
* GNU ``parallel`` (optional)
* ``apptainer`` (optional)
* ``pre-commit`` (optional)

Setup
^^^^^

The `Bats <https://github.com/bats-core/bats-core>`_ testing framework is used
to test the micromamba docker images and derived images. When cloning this
repo you'll want to use ``git clone --recurse-submodules ...``,
which will bring in the git sub-modules for Bats.

`Pre-commit <https://pre-commit.com>`_ should be enabled after cloning the
repo by executing ``pre-commit install`` in the root of the repo.

`Nox <https://nox.thea.codes>`_ is used to automate tests and must be
installed separately.

Executing Tests
^^^^^^^^^^^^^^^

To execute the test suite on all base images, run ``nox`` in the top-level
directory of the repo. To execute the test suite on a single base image, run
``nox --session "tests(base_image='debian:12-slim')"``.

If GNU ``parallel`` is available on the ``$PATH``, then the test suite will be
run in parallel using all logical CPU cores available.

Tests requiring ``apptainer`` will automatically be skipped if ``apptainer``
is not found on the ``$PATH``.

.. _road-map-label:

Road map
--------

Community members are welcomed and encouraged to propose development
work that supports their needs.

The image maintainers are currently working on or planning to work on:

#. Adding non-Debian based distributions that have community interest

   * Add ``public.ecr.aws/amazonlinux/amazonlinux:2023`` as a base image

#. Better supporting conda environment activation when using
   ``apptainer``/``singularity``

#. Improved caching during our image builds such that image digests only are
   modified by pull requests that alter the image. Documentation changes
   should not result in new image digests.

Policies
--------

#. No additional programs or packages are installed into the parent images
   except for those required by ``micromamba``, our helper scripts, and
   ``glibc`` (as conda packges generally have a dependency on ``glibc``).
   We aim to keep our images small and limit our dependencies.

#. Entrypoint script should not write to files in the home directory. On some
   container execution systems, such as ``appatainer``, the host home
   directory is automatically mounted and we don't want to mess up or pollute
   the home directory on the host system.

#. We do not update any packages within the parent images (ie, we do not
   ``apt-get update`` or similar).
