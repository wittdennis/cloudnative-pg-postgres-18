#!/bin/sh

VERSION=$(sed '/POSTGRES_VERSION=/!d' Dockerfile | cut -d'=' -f2)
echo "$VERSION.0"
