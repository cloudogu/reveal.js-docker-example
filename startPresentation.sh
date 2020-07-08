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

CONTAINER_ID=$(docker run  --detach \
    -v $(pwd)/docs/slides:/reveal/docs/slides \
    -v $(pwd)/images:/reveal/images \
    -v $(pwd)/resources:/resources \
    -e TITLE="$(grep -r 'TITLE' Dockerfile | sed "s/.*TITLE='\(.*\)'.*/\1/")" \
    -e THEME_CSS="$(grep -r 'THEME_CSS' Dockerfile | sed "s/.*THEME_CSS='\(.*\)'.*/\1/")" \
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
