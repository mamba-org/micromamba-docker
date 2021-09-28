#!/usr/bin/env python

# pylint: disable=line-too-long,missing-module-docstring,missing-function-docstring,import-error
# flake8: noqa
import itertools
import logging
import sys

from typing import Dict, List

import requests

from semver import VersionInfo


def to_version(ver: str) -> VersionInfo:
    """Converts str to VersionInfo"""
    return VersionInfo.parse(ver)


ARCHITECTURES = ["amd64", "arm64", "ppc64le"]
ANACONDA_PLATFORMS = {"linux-64": "amd64", "linux-aarch64": "arm64", "linux-ppc64le": "ppc64le"}
ANACONDA_API_URL = "https://api.anaconda.org/package/conda-forge/micromamba/files"
DOCKERHUB_API_URL = "https://hub.docker.com/v2/repositories/mambaorg/micromamba/tags/?page_size=25&page=1&ordering=last_updated"


def anaconda_versions(url: str) -> Dict[str, List[VersionInfo]]:
    res = requests.get(url)
    result = res.json()
    out = {arch: [] for arch in ARCHITECTURES}
    for dist in result:
        try:
            arch = ANACONDA_PLATFORMS[dist["attrs"]["subdir"]]
            out[arch].append(to_version(dist["version"]))
        except KeyError:
            pass
    logging.debug('Anaconda versions=%s', out)
    return out


def dockerhub_versions(url: str) -> Dict[str, List[VersionInfo]]:
    dh_res = requests.get(url)
    dh_result = dh_res.json()
    out = {arch: [] for arch in ARCHITECTURES}
    for release in dh_result["results"]:
        if release["name"] != "latest":
            for image in release["images"]:
                arch = image["architecture"]
                if arch in ARCHITECTURES:
                    out[arch].append(to_version(release["name"]))
    logging.debug('Dockerhub versions=%s', out)
    return out


def max_version_available_for_all_arch(versions):
    set_per_arch = [set(v) for v in versions.values()]
    all_arch_versions = set.intersection(*set_per_arch)
    return max(all_arch_versions)


def combined_version_list(versions):
    """Union of versions from all arch"""
    set_per_arch = [set(v) for v in versions.values()]
    return list(set.union(*set_per_arch))


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    conda_versions = anaconda_versions(ANACONDA_API_URL)
    if not conda_versions:
        print("no_version_found")
        sys.exit(0)
    image_versions = dockerhub_versions(DOCKERHUB_API_URL)
    all_image_versions = combined_version_list(image_versions)
    conda_latest = max_version_available_for_all_arch(conda_versions)
    if image_versions:
        if conda_latest not in all_image_versions and conda_latest > max(all_image_versions):
            print(conda_latest)
        else:
            print("no_version_found")
    else:
        print(conda_latest)
