#!/usr/bin/env bash

# When updating, also update in Jenkinsfile. Or use this script in Jenkins
HEADLESS_CHROME_IMAGE='yukinying/chrome-headless-browser:96.0.4662.6'

docker build -t reveal .

container=$(docker run --rm -d reveal)
address=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${container}")
pdf=$(mktemp --suffix=.pdf)

sleep 1

rm "${pdf}" || true

set -x
docker run -v /tmp:/tmp -u "$(id -u)" --entrypoint= -it --shm-size=4G ${HEADLESS_CHROME_IMAGE} \
  /usr/bin/google-chrome-unstable --headless --no-sandbox --disable-gpu --print-to-pdf="${pdf}" --run-all-compositor-stages-before-draw  --virtual-time-budget=10000 \
  "http://${address}:8080/?print-pdf" 

ls -lah "${pdf}"

xdg-open "${pdf}"

docker rm -f "${container}"
