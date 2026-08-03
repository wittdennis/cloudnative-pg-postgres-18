FROM docker.io/library/alpine:3.24.1 AS pg_partman

COPY . /build

WORKDIR /build

# renovate: datasource=github-tags depName=pg_partman packageName=pgpartman/pg_partman versioning=semver
ARG PARTMAN_VERSION=v5.5.0
RUN set -eux && \
    apk add --no-cache "curl" && \
    curl -L "https://github.com/pgpartman/pg_partman/archive/refs/tags/${PARTMAN_VERSION}.tar.gz" --output "pg_partman.tar.gz" && \
    tar -xvf "pg_partman.tar.gz" && \
    mv "pg_partman-${PARTMAN_VERSION:1}" "pg_partman"

FROM ghcr.io/cloudnative-pg/postgresql:18.4-standard-trixie@sha256:f0cc49632b5cc1e51f65ba03658c89bd31d64ea2672b14843a808a8d281417e1
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
