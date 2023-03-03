#!/usr/bin/env bash

COMPRESS=${COMPRESS:-'false'}

set -o errexit -o nounset -o pipefail

PRINTING_IMAGE='arachnysdocker/athenapdf:2.16.0'
# For compression
GHOSTSCRIPT_IMAGE='minidocks/ghostscript:9'

pdf=$(mktemp --suffix=.pdf)
pdfCompressed=${pdf//.pdf/.min.pdf}

image=$(docker build -q . )
container=$(docker run --rm -d "$image")
address=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${container}")

sleep 1

rm "${pdf}" || true

# When images are not printed, increase --delay
docker run --rm --shm-size=4G ${PRINTING_IMAGE} \
  athenapdf --delay 2000 --stdout "http://${address}:8080/?print-pdf" \
  > "${pdf}"

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
