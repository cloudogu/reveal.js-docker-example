$title=(sls 'TITLE' Dockerfile) -replace ".*TITLE='(.*)'.*", "`$1"
$theme=(sls 'THEME_CSS' Dockerfile) -replace ".*THEME_CSS='(.*)'.*", "`$1"
$imageVersion=(sls 'FROM cloudogu/reveal.js' Dockerfile) -replace ".*:([^ ]*) .*", "`$1"

# TODO stop container before running, in order to allow convenient "restart"?
docker run `
    -v ${PWD}/docs/slides:/reveal/docs/slides  `
    -v ${PWD}/images:/reveal/images  `
    -v ${PWD}/resources:/resources `
    -e TITLE=$title `
    -e THEME_CSS=$theme `
    -p 8000:8000 -p 35729:35729  `
   cloudogu/reveal.js:$imageVersion-dev


# TODO run in background, wait for container to come up, then open browser
# echo "Waiting for presentation to become available on http://localhost:8000"
# until $(curl -s -o /dev/null --head --fail localhost:8000); do sleep 1; done
# Start-Process -Path "http://localhotst:8000"

# TODO Print message how to delete container?
pause
