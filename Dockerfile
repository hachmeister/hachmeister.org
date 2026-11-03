FROM ghcr.io/getzola/zola:v0.23.6 AS zola

COPY . /project
WORKDIR /project
RUN ["/zola", "build"]

FROM ghcr.io/static-web-server/static-web-server:2.44.1
WORKDIR /
COPY --from=zola /project/public /public

LABEL wud.watch="true"
LABEL wud.watch.registry="ghcr"
LABEL wud.watch.repository="static-web-server/static-web-server"
LABEL wud.tag.include="^\d+\.\d+\.\d+$"
LABEL wud.tag.semver="true"
