# renovate: datasource=docker depName=ghcr.io/cloudnative-pg/postgresql versioning=docker
ARG POSTGRES_VERSION=18.1

FROM docker.io/library/alpine:3.23.2 AS pg_partman

COPY . /build

WORKDIR /build

# renovate: datasource=github-tags depName=pgpartman/pg_partman versioning=semver
ARG PARTMAN_VERSION=v5.3.1
RUN set -eux && \
    apk add --no-cache "curl" && \
    curl -L "https://github.com/pgpartman/pg_partman/archive/refs/tags/${PARTMAN_VERSION}.tar.gz" --output "pg_partman.tar.gz" && \
    tar -xvf "pg_partman.tar.gz" && \
    mv "pg_partman-${PARTMAN_VERSION:1}" "pg_partman"

FROM ghcr.io/cloudnative-pg/postgresql:${POSTGRES_VERSION}-standard-trixie
COPY --from=pg_partman /build/pg_partman /pg_partman

USER root

RUN set -eux && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends "build-essential" "postgresql-server-dev-18" && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/

RUN set -eux && \
    cd /pg_partman && \
    make install && \
    cd .. && \
    rm -rf /pg_partman && \
    apt-get remove -y "build-essential" "postgresql-server-dev-18" && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/

USER postgres
