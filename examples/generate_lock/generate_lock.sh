docker run --rm -v "$(pwd):/tmp" \
   "--platform=${DOCKER_PLATFORM}" \
   mambaorg/micromamba:2.1.1 /bin/bash -c "\
     micromamba create --yes --name new_env --file env.yaml \
     && micromamba env export --name new_env --explicit" > env.lock
