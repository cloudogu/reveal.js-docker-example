docker build -t reveal .

container=$(docker run --rm -d reveal)
address=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${container}")
pdf=$(mktemp --suffix=.pdf)

sleep 1

rm "${pdf}" || true

docker run -v /tmp:/tmp -u "$(id -u)" --entrypoint= -it --shm-size=4G yukinying/chrome-headless-browser:85.0.4181.8 \
  /usr/bin/google-chrome-unstable --headless --no-sandbox --disable-gpu --print-to-pdf="${pdf}" "http://${address}:8080/?print-pdf"

ls -lah "${pdf}"

xdg-open "${pdf}"

docker rm -f "${container}"
