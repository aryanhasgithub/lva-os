#!/usr/sh
set -e

echo "Waiting for Docker daemon..."
while ! docker version 2>/dev/null >/dev/null; do
    sleep 1
done

echo "Loading LVA container stack..."
for image in $(ls -S /build/images/*.tar); do
	docker load --input "${image}"
done

supervisor=$(docker images --filter "label=io.lva.type=supervisor" --quiet)
docker tag "${supervisor}" "ghcr.io/aryanhasgithub/lva-supervisor:latest"