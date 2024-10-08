Tags
====

The set of tags includes permutations of:

* full or partial version numbers corresponding to the ``micromamba`` version
  within the image
* git commit hashes (``git-<HASH>``, where ``<HASH>`` is the first 7 characters
  of the git commit hash in
  `mamba-org/micromamba-docker
  <https://github.com/mamba-org/micromamba-docker/>`_)
* base image name
   * for Alpine base images, this portion of the tag is set to
     ``alpine<alpine_version>``
   * for CUDA base images, this portion of the tag is set to
     ``cuda<cuda_version>-ubuntu<ubuntu_version>``
   * for Debian base images, this portion of the tag is set to
     ``debian<debian_version>`` plus ``-slim`` if derived from a slim image
   * for Ubuntu base images, this portion of the tag is set to
     ``ubuntu<ubuntu_version>``
   * for AmazonLinux base images, this portion of the tag is set to
     ``amazon<release_year>``

The tag ``latest`` is based on the ``slim`` image of the most recent Debian
release, currently ``12-slim``.

Tags that do not contain ``git`` are rolling tags, meaning these tags get
reassigned to new images each time these images are built.

To reproducibly build images derived from these ``micromamba`` images, the best
practice is for the Dockerfile ``FROM`` command to reference the image's sha256
digest and not use tags.
