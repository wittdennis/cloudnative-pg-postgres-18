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

FROM docker.io/library/alpine:3.24.1 AS pgvector

COPY . /build

WORKDIR /build

# renovate: datasource=github-tags depName=pgvector packageName=pgvector/pgvector versioning=semver
ARG PGVECTOR_VERSION=v0.8.3
RUN set -eux && \
    apk add --no-cache "curl" && \
    curl -L "https://github.com/pgvector/pgvector/archive/refs/tags/${PGVECTOR_VERSION}.tar.gz" --output "pgvector.tar.gz" && \
    tar -xvf "pgvector.tar.gz" && \
    mv "pgvector-${PGVECTOR_VERSION:1}" "pgvector"

FROM ghcr.io/cloudnative-pg/postgresql:18.6-standard-trixie@sha256:771f9eab5225587af259d84680cc69a5b6e374ac32bb24effafde1f3368a1241
COPY --from=pg_partman /build/pg_partman /pg_partman
COPY --from=pgvector /build/pgvector /pgvector

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
    cd /pgvector && \
    make install && \
    cd .. && \
    rm -rf /pgvector && \
    apt-get remove -y "build-essential" "postgresql-server-dev-18" && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/

USER postgres
