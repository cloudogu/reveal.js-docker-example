FROM cloudogu/reveal.js:5.1.0-r1 as base

FROM base as aggregator
ENV TITLE='Cloudogu - reveal.js-docker'
ENV THEME_CSS='cloudogu-black.css'
ENV WIDTH='1280'
USER root
# Remove demo slides before templating
RUN rm -rf  /reveal/docs
COPY . /reveal
RUN if [ -d /reveal/resources/ ]; then mv /reveal/resources/ /; fi
RUN /scripts/templateIndexHtml

FROM base
ENV SKIP_TEMPLATING='true'
COPY --from=aggregator --chown=nginx /reveal /reveal