docker run --rm -v "$(pwd):/tmp" \
   mambaorg/micromamba:1.5.7 /bin/bash -c "\
     micromamba create --yes --name new_env --file env.yaml \
     && micromamba env export --name new_env --explicit" > env.lock
