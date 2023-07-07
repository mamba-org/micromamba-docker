Making Small Images
===================

Uwe Korn has a nice `blog post
<https://uwekorn.com/2021/03/01/deploying-conda-environments-in-docker-how-to-do-it-right.html>`_
on making small images containing conda environments that is a good resource.
He uses ``mamba`` instead of ``micromamba``, but the general concepts still
apply when using ``micromamba``.

If final image size is a priority, then try using an image with a tag that
contains ``alpine``. Our alpine-based images come pre-loaded with glibc,
which should enable them to run most conda packages, but extra testing
is recommended when using the alpine-based images.
