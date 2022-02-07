# pylint: disable=missing-module-docstring,missing-function-docstring,import-error
import semver

import check_version

ANACONDA_JSON = [
    {
        "description": None,
        "basename": "linux-64/micromamba-0.3.8-hc2cb875_0.tar.bz2",
        "labels": ["main"],
        "dependencies": {
            "depends": [
                {"name": "libgcc-ng", "specs": [[">=", "7.5.0"]]},
                {"name": "libstdcxx-ng", "specs": [[">=", "7.5.0"]]},
            ]
        },
        "distribution_type": "conda",
        "attrs": {
            "build_number": 0,
            "license": "BSD-3-Clause",
            "has_prefix": True,
            "license_family": "BSD",
            "machine": "x86_64",
            "platform": "linux",
            "depends": ["libgcc-ng >=7.5.0", "libstdcxx-ng >=7.5.0"],
            "build": "hc2cb875_0",
            "timestamp": 1592982666827,
            "arch": "x86_64",
            "operatingsystem": "linux",
            "target-triplet": "x86_64-any-linux",
            "subdir": "linux-64",
        },
        "full_name": "conda-forge/micromamba/0.3.8/linux-64/micromamba-0.3.8-hc2cb875_0.tar.bz2",
        "owner": "conda-forge",
        "size": 4454401,
        "upload_time": "2020-06-24 07:11:34.659000+00:00",
        "ndownloads": 1132,
        "download_url": (
            "//api.anaconda.org/download/conda-forge/micromamba/0.3.8/linux-64/"
            "micromamba-0.3.8-hc2cb875_0.tar.bz2"
        ),
        "version": "0.3.8",
        "md5": "751085539d9ed8598f7db9dbf91a9fcb",
        "type": "conda",
    },
    {
        "description": None,
        "basename": "linux-aarch64/micromamba-0.3.8-hc2cb875_0.tar.bz2",
        "labels": ["main"],
        "dependencies": {
            "depends": [
                {"name": "libgcc-ng", "specs": [[">=", "7.5.0"]]},
                {"name": "libstdcxx-ng", "specs": [[">=", "7.5.0"]]},
            ]
        },
        "distribution_type": "conda",
        "attrs": {
            "build_number": 0,
            "license": "BSD-3-Clause",
            "has_prefix": True,
            "license_family": "BSD",
            "machine": "aarch64",
            "platform": "linux",
            "depends": ["libgcc-ng >=7.5.0", "libstdcxx-ng >=7.5.0"],
            "build": "hc2cb875_0",
            "timestamp": 1593025081387,
            "arch": "aarch64",
            "operatingsystem": "linux",
            "target-triplet": "aarch64-any-linux",
            "subdir": "linux-aarch64",
        },
        "full_name": "conda-forge/micromamba/0.3.8/linux-aarch64/micromamba-0.3.8-hc2cb875_0.tar.bz2",
        "owner": "conda-forge",
        "size": 4452195,
        "upload_time": "2020-06-24 18:58:29.159000+00:00",
        "ndownloads": 25,
        "download_url": (
            "//api.anaconda.org/download/conda-forge/micromamba/0.3.8/linux-aarch64/"
            "micromamba-0.3.8-hc2cb875_0.tar.bz2"
        ),
        "version": "0.3.8",
        "md5": "7774e228e218e9a986ed5961bd1b6525",
        "type": "conda",
    },
    {
        "description": None,
        "basename": "linux-ppc64le/micromamba-0.3.8-hb9d3100_0.tar.bz2",
        "labels": ["main"],
        "dependencies": {
            "depends": [
                {"name": "libgcc-ng", "specs": [[">=", "8.4.0"]]},
                {"name": "libstdcxx-ng", "specs": [[">=", "8.4.0"]]},
            ]
        },
        "distribution_type": "conda",
        "attrs": {
            "build_number": 0,
            "license": "BSD-3-Clause",
            "has_prefix": True,
            "license_family": "BSD",
            "machine": "ppc64le",
            "platform": "linux",
            "depends": ["libgcc-ng >=8.4.0", "libstdcxx-ng >=8.4.0"],
            "build": "hb9d3100_0",
            "timestamp": 1593025186943,
            "arch": "ppc64le",
            "operatingsystem": "linux",
            "target-triplet": "ppc64le-any-linux",
            "subdir": "linux-ppc64le",
        },
        "full_name": "conda-forge/micromamba/0.3.8/linux-ppc64le/micromamba-0.3.8-hb9d3100_0.tar.bz2",
        "owner": "conda-forge",
        "size": 4839487,
        "upload_time": "2020-06-24 19:00:12.333000+00:00",
        "ndownloads": 24,
        "download_url": (
            "//api.anaconda.org/download/conda-forge/micromamba/0.3.8/linux-ppc64le/"
            "micromamba-0.3.8-hb9d3100_0.tar.bz2"
        ),
        "version": "0.3.8",
        "md5": "e3cc9c4203247439271b77e858646625",
        "type": "conda",
    },
]

DOCKERHUB_JSON = {
    "count": 51,
    "next": (
        "https://hub.docker.com/v2/repositories/mambaorg/micromamba/tags/"
        "?ordering=last_updated&page=2&page_size=1"
    ),
    "previous": None,
    "results": [
        {
            "creator": 3115525,
            "id": 173124566,
            "image_id": None,
            "images": [
                {
                    "architecture": "arm64",
                    "features": "",
                    "variant": None,
                    "digest": "sha256:74119eaf6896b17dafee1a8b9e08e6b395c167a561b007a4a079772ee3a1b40b",
                    "os": "linux",
                    "os_features": "",
                    "os_version": None,
                    "size": 36767982,
                    "status": "active",
                    "last_pulled": "2022-02-06T18:12:34.885807Z",
                    "last_pushed": "2022-02-06T17:04:25.495163Z",
                },
                {
                    "architecture": "ppc64le",
                    "features": "",
                    "variant": None,
                    "digest": "sha256:133d2f7a089ea2f7e58db5c9ae2031fc030728011d8480a615fa1c9b58455aa4",
                    "os": "linux",
                    "os_features": "",
                    "os_version": None,
                    "size": 42658067,
                    "status": "active",
                    "last_pulled": "2022-02-06T18:12:34.881309Z",
                    "last_pushed": "2022-02-06T17:04:25.828317Z",
                },
                {
                    "architecture": "amd64",
                    "features": "",
                    "variant": None,
                    "digest": "sha256:d0e360c35c8f82ee1c48832eba01fbd06ac03f8732fedd48f0d24345b326a7eb",
                    "os": "linux",
                    "os_features": "",
                    "os_version": None,
                    "size": 37828965,
                    "status": "active",
                    "last_pulled": "2022-02-06T21:11:23.318889Z",
                    "last_pushed": "2022-02-06T17:04:25.211824Z",
                },
            ],
            "last_updated": "2022-02-06T17:04:28.933198Z",
            "last_updater": 3115525,
            "last_updater_username": "wolfv",
            "name": "0.2.0",
            "repository": 11222397,
            "full_size": 37828965,
            "v2": True,
            "tag_status": "active",
            "tag_last_pulled": "2022-02-06T21:11:23.318889Z",
            "tag_last_pushed": "2022-02-06T17:04:28.933198Z",
        }
    ],
}


def test_combined_version_list01():
    arch_ver = {"arch1": [semver.VersionInfo.parse("1.0.0")], "arch2": [semver.VersionInfo.parse("2.0.0")]}
    versions = {
        semver.VersionInfo(major=1, minor=0, patch=0, prerelease=None, build=None),
        semver.VersionInfo(major=2, minor=0, patch=0, prerelease=None, build=None),
    }
    assert set(check_version.combined_version_list(arch_ver)) == versions


def test_combined_version_list02():
    arch_ver = {"arch1": []}
    assert len(check_version.combined_version_list(arch_ver)) == 0


def test_max_version_available_for_all_arch01():
    arch_ver = {
        "arch1": [semver.VersionInfo.parse("2.0.0"), semver.VersionInfo.parse("1.0.1")],
        "arch2": [semver.VersionInfo.parse("2.0.0"), semver.VersionInfo.parse("2.0.1")],
    }
    assert check_version.max_version_available_for_all_arch(arch_ver) == semver.VersionInfo.parse("2.0.0")


def test_max_version_available_for_all_arch02():
    arch_ver = {"arch1": [semver.VersionInfo.parse("1.0.0")], "arch2": [semver.VersionInfo.parse("2.0.0")]}
    assert check_version.max_version_available_for_all_arch(arch_ver) is None


def mocked_requests_get(*args, **_):
    # pylint: disable=too-few-public-methods
    class MockResponse:
        """for mocking http request responses"""

        def __init__(self, json_data, status_code):
            self.json_data = json_data
            self.status_code = status_code

        def json(self):
            return self.json_data

    if args[0].startswith("https://hub.docker.com/v2"):
        return MockResponse(DOCKERHUB_JSON, 200)
    if args[0].startswith("https://api.anaconda.org/package"):
        return MockResponse(ANACONDA_JSON, 200)
    return MockResponse(None, 404)


def test_dockerhub_verions01(mocker):
    mocker.patch("requests.get", side_effect=mocked_requests_get)
    expected = {
        "amd64": [semver.VersionInfo(major=0, minor=2, patch=0, prerelease=None, build=None)],
        "arm64": [semver.VersionInfo(major=0, minor=2, patch=0, prerelease=None, build=None)],
        "ppc64le": [semver.VersionInfo(major=0, minor=2, patch=0, prerelease=None, build=None)],
    }
    assert check_version.dockerhub_versions(check_version.DOCKERHUB_API_URL) == expected


def test_anaconda_versions01(mocker):
    mocker.patch("requests.get", side_effect=mocked_requests_get)
    expected = {
        "amd64": [semver.VersionInfo(major=0, minor=3, patch=8, prerelease=None, build=None)],
        "arm64": [semver.VersionInfo(major=0, minor=3, patch=8, prerelease=None, build=None)],
        "ppc64le": [semver.VersionInfo(major=0, minor=3, patch=8, prerelease=None, build=None)],
    }
    assert check_version.anaconda_versions(check_version.ANACONDA_API_URL) == expected


def test_get_version_and_build_status01(mocker):
    mocker.patch("requests.get", side_effect=mocked_requests_get)
    assert check_version.get_version_and_build_status() == (
        semver.VersionInfo(major=0, minor=3, patch=8, prerelease=None, build=None),
        True,
    )
