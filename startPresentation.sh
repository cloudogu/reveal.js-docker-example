#!/usr/bin/env bash

ARGUMENT=${1}

set -o errexit -o nounset -o pipefail
set -o monitor # Job Control, needed for "fg"
echo "Starting presentation" 

INTERNAL=""
DOCKER_ARGS="-p 8000:8000 -p 35729:35729"

if [[ "${ARGUMENT}" == "internal" ]]; then
    INTERNAL=true
    DOCKER_ARGS=""
fi

# shellcheck disable=SC2046
# Quoting leads to '' which in turn leads to failing docker command
# For dist/theme: Don't mount whole folder to not overwrite other files in folder (fonts, images, etc.)
CONTAINER_ID=$(docker run  --detach \
    $([[ -d docs/slides ]] && echo "-v $(pwd)/docs/slides:/reveal/docs/slides") \
    $([[ -d dist/theme ]] && for f in dist/theme/*.css; do echo "-v $(pwd)/${f}:/reveal/${f}"; done) \
    $([[ -d images ]] && echo "-v $(pwd)/images:/reveal/images") \
    $([[ -d resources ]] && echo "-v $(pwd)/resources:/resources") \
    $([[ -d plugin ]] && for dir in plugin/*/; do echo "-v $(pwd)/${dir}:/reveal/${dir}"; done) \
    -e TITLE="$(grep -r 'TITLE' Dockerfile | sed "s/.*TITLE='\(.*\)'.*/\1/")" \
    -e THEME_CSS="$(grep -r 'THEME_CSS' Dockerfile | sed "s/.*THEME_CSS='\(.*\)'.*/\1/")" \
    -e ADDITIONAL_PLUGINS="$(grep -r 'ADDITIONAL_PLUGINS' Dockerfile | sed "s/.*ADDITIONAL_PLUGINS='\(.*\)'.*/\1/")" \
    -e ADDITIONAL_SCRIPT="$(grep -r 'ADDITIONAL_SCRIPT' Dockerfile | sed "s/.*ADDITIONAL_SCRIPT='\(.*\)'.*/\1/")" \
    ${DOCKER_ARGS} \
   cloudogu/reveal.js:$(head -n1 Dockerfile | sed 's/.*:\([^ ]*\) .*/\1/')-dev)

# Print logs in background while waiting for container to come up
docker logs ${CONTAINER_ID}
docker attach ${CONTAINER_ID} &

if [[ "${INTERNAL}" == "true" ]]; then
    REVEAL_HOSTNAME=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${CONTAINER_ID})
else
    REVEAL_HOSTNAME=localhost
fi

echo "Waiting for presentation to become available on http://${REVEAL_HOSTNAME}:8000"

until $(curl -s -o /dev/null --head --fail ${REVEAL_HOSTNAME}:8000); do sleep 1; done

# Open Browser
xdg-open http://${REVEAL_HOSTNAME}:8000

# Bring container to foreground, so it can be stopped using ctrl+c. 
# But don't output "docker attach ${CONTAINER_ID}"
fg > /dev/null
