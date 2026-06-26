#!/usr/bin/env bash
set -e
set -u
set -o pipefail

# Argument mapping
version=$1
oci_arch=$2
dl_dir=$3
dst_dir=$4
image_name=$5 # Accept image name parameter (e.g., lva-supervisor, lva-cli, lva-audio)

image="ghcr.io/aryanhasgithub/${image_name}"
full_image_name="${image}:${version}"

retry() {
    local retries="$1"
    local cmd=$2
    local delay=5
    local output
    local rc
    output=$(eval "$cmd") && rc=$? || rc=$?
    while [ "$rc" -ne 0 ] && [ "$retries" -gt 0 ]; do
        echo "Retrying \"$cmd\" in ${delay}s ($retries retries left)..." >&2
        sleep "${delay}s"
        delay=$((delay * 3))
        retries=$((retries - 1))
        output=$(eval "$cmd") && rc=$? || rc=$?
    done
    echo "$output"
    return $rc
}

image_digest=$(retry 3 "skopeo inspect --override-arch '${oci_arch}' 'docker://${full_image_name}' | jq -r '.Digest'")

image_file_name="${full_image_name//[:\/]/_}@${image_digest//[:\/]/_}"
image_file_path="${dl_dir}/${image_file_name}.tar"
dst_image_file_path="${dst_dir}/${image_name}.tar"

(
    flock --verbose 3
    if [ ! -f "${image_file_path}" ]; then
        echo "Fetching image: ${full_image_name} (digest ${image_digest})"
        retry 3 "skopeo copy --override-arch '${oci_arch}' 'docker://${image}@${image_digest}' 'oci-archive:${image_file_path}:${full_image_name}'"
    else
        echo "Skipping download of existing image: ${full_image_name} (digest ${image_digest})"
    fi
    cp "${image_file_path}" "${dst_image_file_path}"
) 3>"${image_file_path}.lock"
