#!/usr/sh
set -e

echo "Waiting for Docker daemon..."
while ! docker version 2>/dev/null >/dev/null; do
    sleep 1
done

echo "Loading LVA container stack..."
for img in lva-supervisor lva-cli lva-audio; do
    if [ -f "/build/images/${img}.tar" ]; then
        echo "Loading ${img} image..."
        docker load --input "/build/images/${img}.tar"
    else
        echo "Warning: /build/images/${img}.tar not found, skipping."
    fi
done

echo "Done loading images."
