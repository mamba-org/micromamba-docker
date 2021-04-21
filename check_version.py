import requests
import semver


def to_version(s):
    return semver.VersionInfo.parse(s)


anaconda_api_url = "https://api.anaconda.org/release/conda-forge/micromamba/latest"
dockerhub_api_url = "https://hub.docker.com/v2/repositories/mambaorg/micromamba/tags/?page_size=25&page=1&ordering=last_updated"

ac_res = requests.get(anaconda_api_url)
dh_res = requests.get(dockerhub_api_url)

result = ac_res.json()

for dist in result["distributions"]:
    if dist["attrs"]["subdir"] == "linux-64":
        latest_version = to_version(dist["version"])
        break

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
