Development
===========

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

The `Bats <https://github.com/bats-core/bats-core>`_ testing framework is used
to test the micromamba docker images and derived images. When cloning this
repo you'll want to use ``git clone --recurse-submodules ...``,
which will bring in the git sub-modules for Bats.
`Nox <https://nox.thea.codes>`_ is used to automate tests and must be
installed separately. To execute the test suite on all base
images, run ``nox`` in the top-level directory of the repo. To execute the test
suite on a single base image, run
``nox --session "tests(base_image='debian:bullseye-slim')"``.
If GNU ``parallel`` is available on the ``$PATH``, then the test suite will be run
in parallel using all logical CPU cores available.

`Pre-commit <https://pre-commit.com>`_ should be enabled after cloning the
repo by executing ``pre-commit install`` in the root of the repo.

.. _road-map-label:

Road map
--------

The current road map for expanding the number of base images and supported
shells is as follows:

#. Add non-Debian based distributions that have community interest
#. Add support for non-``bash`` shells based on community interest

The build and test infrastructure will need to be altered to support additional
base images such that automated test and build occur for all images produced.

Policies
--------

#. Entrypoint script should not write to files in the home directory. On some
   container execution systems, the host home directory is automatically
   mounted and we don't want to mess up or pollute the home directory on the
   host system.
