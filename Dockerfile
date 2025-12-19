FROM ghcr.io/cloudogu/reveal.js:5.2.1-r3 as aggregator
ENV TITLE='Cloudogu - reveal.js-docker'
ENV THEME_CSS='cloudogu-black.css'
ENV WIDTH='1280'
USER root
# Remove demo slides before templating
RUN rm -rf  /reveal/docs
COPY . /reveal
RUN if [ -d /reveal/resources/ ]; then mv /reveal/resources/ /; fi
RUN /scripts/templateIndexHtml

FROM nginxinc/nginx-unprivileged:1-alpine-slim
#FROM ghcr.io/nginx/nginx-unprivileged:1-alpine no rate limits, but no slim. 53M instead of 17M unpacked 😐️
COPY --from=aggregator --chown=nginx /reveal /usr/share/nginx/html

# FROM ghcr.io/cloudogu/reveal.js is also possible but not relying on a 3rd party image requires less trust
# ENV SKIP_TEMPLATING='true'
# COPY --from=aggregator --chown=nginx /reveal /reveal
