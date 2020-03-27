#!/usr/bin/env bash

echo "Starting presentation on localhost:8000" 

docker run --rm \
    -v $(pwd)/docs/slides:/reveal/docs/slides \
    -v $(pwd)/resources:/resources \
    -e TITLE="$(grep -r 'TITLE' Dockerfile | sed "s/.*TITLE='\(.*\)'.*/\1/")" \
    -p 8000:8000 -p 35729:35729 \
    cloudogu/reveal.js:$(head -n1 Dockerfile | sed 's/.*:\([^ ]*\) .*/\1/')-dev