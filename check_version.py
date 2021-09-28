#!/usr/bin/env python
# pylint: disable=line-too-long,missing-module-docstring
import argparse
import logging
import requests
import semver
import sys


from semver import VersionInfo
from typing import List, Optional


def to_version(ver: str) -> VersionInfo:
    """Converts str to semver.VersionInfo"""
    return semver.VersionInfo.parse(ver)


ARCHITECTURES = ["amd64", "arm64", "ppc64le"]
ANACONDA_PLATFORMS = {"amd64": "linux-64", "arm64": "linux-aarch64", "ppc64le": "linux-ppc64le"}
ANACONDA_API_URL = "https://api.anaconda.org/package/conda-forge/micromamba/files"
DOCKERHUB_API_URL = "https://hub.docker.com/v2/repositories/mambaorg/micromamba/tags/?page_size=25&page=1&ordering=last_updated"


def anaconda_versions(url: str, arch: str) -> Optional[VersionInfo]:
    res = requests.get(url)
    result = res.json()
    out = [to_version(dist["version"]) for dist in result
           if dist["attrs"]["subdir"] == ANACONDA_PLATFORMS[arch]]
    logging.debug('Anaconda versions=%s', out)
    return out


def dockerhub_versions(url: str, arch: str) -> List[VersionInfo]:
    dh_res = requests.get(url)
    dh_result = dh_res.json()
    out = []
    for release in dh_result["results"]:
        if release["name"] != "latest":
            for image in release["images"]:
                if image["architecture"] == arch:
                    out.append(to_version(release["name"]))
    logging.debug('Dockerhub versions=%s', out)
    return out


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    parser = argparse.ArgumentParser(description='Test if dockerhub has older version than conda forge.')
    parser.add_argument('arch', help=f"Architecture to test. One of: {','.join(ARCHITECTURES)}")
    args = parser.parse_args()
    assert args.arch in ARCHITECTURES
    conda_versions = anaconda_versions(ANACONDA_API_URL, args.arch)
    if not conda_versions:
        print("no_version_found")
        sys.exit(0)
    image_versions = dockerhub_versions(DOCKERHUB_API_URL, args.arch)
    conda_latest = max(conda_versions)
    if image_versions:
        if conda_latest not in image_versions and conda_latest > max(image_versions):
            print(conda_latest)
        else:
            print("no_version_found")
    else:
        print(conda_latest)
