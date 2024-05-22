#!/usr/bin/env bash

COMPRESS=${COMPRESS:-'false'}

set -o errexit -o nounset -o pipefail

PRINTING_IMAGE='ghcr.io/puppeteer/puppeteer:22'
# For compression
GHOSTSCRIPT_IMAGE='minidocks/ghostscript:9'

pdf=$(mktemp --suffix=.pdf)
pdfCompressed=${pdf//.pdf/.min.pdf}

image=$(docker build -q . )
container=$(docker run --rm -d "$image")
address=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${container}")

sleep 1

rm "${pdf}" || true

# See https://pptr.dev/guides/docker, https://pptr.dev/guides/pdf-generation
docker run -i --init --cap-add=SYS_ADMIN --rm -v /tmp:/tmp ${PRINTING_IMAGE} node -e "
const puppeteer = require('puppeteer');
(async () => {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    await page.goto('http://${address}:8080/?view=print', { waitUntil: 'networkidle2' });
    await page.pdf({ path: '${pdf}', width: '1331px', height: '727px' });
    await browser.close();
})();"

# Puppeteer runs as it's own user and therefore the PDF has wrong owner
# Correct this the hard way 
docker run --rm -u0 -v /tmp:/tmp ${PRINTING_IMAGE} chown "$(id -u):$(id -g)" "${pdf}"
# Are there any alternatives?
# Changing ownership in puppeteer is not possible, because unpriv puppeteer user is not allowed to change ownership 
# Running puppeteer 
# Running puppeteer as root is worse, because chrome would have to run without sandbox, which is bad for security

if [[ $COMPRESS == "true" ]]; then
  # Compress defensively, using best quality PDFSETTING printer.
  # Still five times smaller thant original 
  # Other dPDFSETTINGS: printer > default > ebook > screen
  # https://askubuntu.com/a/256449/
  docker run --rm -v /tmp:/tmp $GHOSTSCRIPT_IMAGE \
    -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dQUIET -dBATCH \
    -sOutputFile=- "${pdf}" \
    > "${pdfCompressed}"
fi 

finalPdf="$(if [[ $COMPRESS == "true" ]]; then echo "${pdfCompressed}"; else echo "${pdf}"; fi)"

if [ -t 1 ] ; then
  # When running in terminal print both PDF with size and opn
  ls -lah "${pdf//.pdf/}"*
  xdg-open "${finalPdf}"
else
  # For headless use only output path to PDF
  echo "${finalPdf}"
fi

# Dont leak PDFs, containers or images
if [[ $COMPRESS == "true" ]]; then rm "${pdf}"; fi
docker rm -f "${container}" > /dev/null
# Image might still be in use, but at least try to clean up image 
docker rmi "${image}" > /dev/null || true
