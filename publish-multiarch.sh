#!/bin/sh

docker buildx build \
 --push \
 --platform linux/arm64,linux/amd64 \
 --tag gh0st42/coreemu7 .