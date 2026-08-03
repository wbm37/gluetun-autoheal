# Stage 1: extract docker CLI and compose plugin.
# Keep the Docker CLI source explicit when this fork is rebuilt.
ARG DOCKER_CLI_IMAGE=docker:cli@sha256:206ae9cc405101ab0cf97d4b515d21bf6aae961f98f7f9d8de6c111718fef335
ARG ALPINE_IMAGE=alpine:latest@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b
FROM ${DOCKER_CLI_IMAGE} AS docker-source

# Stage 2: minimal Alpine with only what we need
FROM ${ALPINE_IMAGE}

RUN apk add --no-cache curl ca-certificates && apk upgrade --no-cache

# Copy only the two binaries we use
COPY --from=docker-source /usr/local/bin/docker /usr/local/bin/docker
COPY --from=docker-source /usr/local/libexec/docker/cli-plugins/docker-compose \
                           /usr/local/libexec/docker/cli-plugins/docker-compose

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV GLUETUN_CONTAINER=gluetun \
    GLUETUN_DEPS=qbittorrent \
    COMPOSE_FILE=/workspace/docker-compose.yml \
    ENV_FILE=/workspace/.env \
    AUTOHEAL_INTERVAL=30 \
    AUTOHEAL_LABEL=autoheal=true

ENTRYPOINT ["/entrypoint.sh"]
