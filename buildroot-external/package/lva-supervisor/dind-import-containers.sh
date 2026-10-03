#!/bin/sh
set -e

echo "Waiting for Docker daemon..."
while ! docker version 2>/dev/null >/dev/null; do
    sleep 1
done

echo "Loading LVA container stack..."
for image in /build/images/*.tar; do
    docker load --input "${image}"
done

for repo in lva-supervisor lva-cli lva-audio; do
    full="ghcr.io/aryanhasgithub/${repo}"
    tag=$(docker images --format '{{.Repository}}:{{.Tag}}' "${full}" | head -n1)
    docker tag "${tag}" "${full}:latest"
done
