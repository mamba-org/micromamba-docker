import requests
import semver


def to_version(s):
    return semver.VersionInfo.parse(s)

platforms = ["linux-64", "linux-aarch64", "linux-ppc64le"]
anaconda_api_url = "https://api.anaconda.org/release/conda-forge/micromamba/latest"
dockerhub_api_url = "https://hub.docker.com/v2/repositories/mambaorg/micromamba/tags/?page_size=25&page=1&ordering=last_updated"

ac_res = requests.get(anaconda_api_url)
dh_res = requests.get(dockerhub_api_url)

result = ac_res.json()

latest_version = None
for dist in result["distributions"]:
    if dist["attrs"]["subdir"] in platforms:
        platform_version = to_version(dist["version"])
        if latest_version is None:
            latest_version = platform_version
        elif platform_version != latest_version:
            print("no_version_found")
            exit(0)

dh_result = dh_res.json()
docker_versions = []
for image in dh_result["results"]:
    if image["name"] != "latest":
        docker_versions.append(to_version(image["name"]))

if docker_versions:
    if latest_version not in docker_versions and latest_version > max(docker_versions):
        print(latest_version)
    else:
        print("no_version_found")
else:
    print(latest_version)
