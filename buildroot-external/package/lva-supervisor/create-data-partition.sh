#!/usr/bin/env bash
set -e

build_dir=$1
dst_dir=$2
docker_version=$3

data_img="${dst_dir}/data.ext4"
data_dir="${build_dir}/data"

# Make image
rm -f "${data_img}"
truncate --size="1280M" "${data_img}"
mkfs.ext4 -L "lvaos-data" -E lazy_itable_init=0,lazy_journal_init=0 "${data_img}"

# Mount
mkdir -p "${data_dir}"
sudo mount -o loop,discard "${data_img}" "${data_dir}"
trap 'docker rm -f ${container} > /dev/null; sudo umount ${data_dir} || true' ERR EXIT

# Docker-in-Docker to import supervisor image into the data partition
container=$(docker run --privileged -e DOCKER_TLS_CERTDIR="" \
    -v "${data_dir}":/mnt/data \
    -v "${build_dir}":/build \
    -d "docker:${docker_version}-dind" --feature containerd-snapshotter --data-root /mnt/data/docker)

docker exec "${container}" sh /build/dind-import-containers.sh

sudo bash -ex <<'INNEREOF'
touch "${data_dir}/.docker-use-containerd-snapshotter"
mkdir -p "${data_dir}/supervisor"
INNEREOF

# Tear down
docker rm -f "${container}" > /dev/null
sudo umount "${data_dir}"
trap - ERR EXIT

# Shrink filesystem to minimum size
e2fsck -f -y "${data_img}"
resize2fs -M "${data_img}"

# Truncate image file to match filesystem size
block_count=$(dumpe2fs -h "${data_img}" 2>/dev/null | awk '/^Block count:/{print $3}')
block_size=$(dumpe2fs -h "${data_img}" 2>/dev/null | awk '/^Block size:/{print $3}')
truncate --size="$((block_count * block_size))" "${data_img}"

echo "Data partition created: ${data_img}"