#!/usr/bin/env python

# pylint: disable=line-too-long,missing-module-docstring,missing-function-docstring,import-error
# flake8: noqa
import logging
from typing import Dict, List, Optional, Tuple, Set

import requests
from packaging.version import Version, InvalidVersion

ANACONDA_PLATFORMS = {
    "linux-64": "amd64",
    "linux-aarch64": "arm64",
    "linux-ppc64le": "ppc64le",
}
ARCHITECTURES = list(ANACONDA_PLATFORMS.values())
ANACONDA_API_URL = "https://api.anaconda.org/package/conda-forge/micromamba/files"
DOCKERHUB_API_URL = "https://hub.docker.com/v2/repositories/mambaorg/micromamba/tags/?page_size=25&page=1&ordering=last_updated"


ArchVersions = Dict[str, List[Version]]


def to_version(ver: str) -> Version:
    """Converts str to Version"""
    return Version(ver)


def anaconda_versions(url: str) -> Dict[str, List[Version]]:
    res = requests.get(url)
    result = res.json()
    out: ArchVersions = {arch: [] for arch in ARCHITECTURES}
    for dist in result:
        try:
            arch = ANACONDA_PLATFORMS[dist["attrs"]["subdir"]]
            out[arch].append(to_version(dist["version"]))
        except KeyError:
            pass
    logging.debug("Anaconda versions=%s", out)
    return out


def dockerhub_versions(url: str) -> ArchVersions:
    dh_res = requests.get(url)
    dh_result = dh_res.json()
    out: ArchVersions = {arch: [] for arch in ARCHITECTURES}
    for release in dh_result["results"]:
        version_str = release["name"].split("-")[0]
        for image in release["images"]:
            arch = image["architecture"]
            if arch in ARCHITECTURES:
                try:
                    out[arch].append(to_version(version_str))
                except InvalidVersion:
                    pass
    logging.debug("Dockerhub versions=%s", out)
    return out


def is_regular_version(ver: Version) -> bool:
    """Check if version is regular (not pre/post-release or dev)"""
    return not (ver.is_prerelease or ver.is_postrelease or ver.is_devrelease)


def filter_out_irregular_versions(versions: Set[Version]) -> Set[Version]:
    """Filter out versions that pre/post-release or dev versions"""
    return {ver for ver in versions if is_regular_version(ver)}


def max_version_available_for_all_arch(versions: ArchVersions) -> Optional[Version]:
    set_per_arch = [set(v) for v in versions.values()]
    all_arch_versions = set.intersection(*set_per_arch)
    all_regular_arch_versions = filter_out_irregular_versions(all_arch_versions)
    try:
        return max(all_regular_arch_versions)
    except ValueError:
        return None


def combined_version_list(versions: ArchVersions) -> List[Version]:
    """Union of versions from all arch"""
    set_per_arch = [set(v) for v in versions.values()]
    return list(set.union(*set_per_arch))


def get_version_and_build_status() -> Tuple[Optional[Version], bool]:
    logging.basicConfig(level=logging.DEBUG)
    conda_versions = anaconda_versions(ANACONDA_API_URL)
    conda_latest = max_version_available_for_all_arch(conda_versions)
    if conda_latest is None:
        build_required = False
    else:
        image_versions_by_arch = dockerhub_versions(DOCKERHUB_API_URL)
        image_versions = combined_version_list(image_versions_by_arch)
        if image_versions:
            build_required = conda_latest not in image_versions and conda_latest > max(image_versions)
        else:
            build_required = True
    logging.debug("conda_latest=%s", conda_latest)
    logging.debug("build_required=%s", build_required)
    return conda_latest, build_required


if __name__ == "__main__":
    version, build = get_version_and_build_status()
    print(f"{version},{build}")
