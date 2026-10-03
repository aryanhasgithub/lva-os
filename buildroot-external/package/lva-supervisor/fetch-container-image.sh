#!/usr/bin/env bash
set -e
set -u
set -o pipefail

oci_arch=$1
version_json=$2
image_json_name=$3
dl_dir=$4
dst_dir=$5

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

image="ghcr.io/aryanhasgithub/${image_json_name}"
image_tag=$(jq -e -r --arg image_json_name "${image_json_name}" \
	'.[$image_json_name].version' < "${version_json}")
full_image_name="${image}:${image_tag}"

image_digest=$(retry 3 "skopeo inspect --override-arch '${oci_arch}' 'docker://${full_image_name}' | jq -r '.Digest'")

# The arch MUST be part of the cache key: for multi-arch tags the digest above
# is the manifest-list digest, which is the same for every architecture.
image_file_name="${full_image_name//[:\/]/_}_${oci_arch}@${image_digest//[:\/]/_}"
image_file_path="${dl_dir}/${image_file_name}.tar"
dst_image_file_path="${dst_dir}/${image_file_name}.tar"

(
    flock --verbose 3
    if [ ! -f "${image_file_path}" ]; then
        echo "Fetching image: ${full_image_name} [${oci_arch}] (digest ${image_digest})"
        retry 3 "skopeo copy --override-arch '${oci_arch}' 'docker://${image}@${image_digest}' 'oci-archive:${image_file_path}:${full_image_name}'"
    else
        echo "Skipping download of existing image: ${full_image_name} [${oci_arch}] (digest ${image_digest})"
    fi

    # Verify what is actually inside the tarball. skopeo does not fail when a
    # single-arch image doesn't match --override-arch, it just copies it.
    actual_arch=$(skopeo inspect --config "oci-archive:${image_file_path}:${full_image_name}" | jq -r '.architecture')
    if [ "${actual_arch}" != "${oci_arch}" ]; then
        echo "ERROR: ${full_image_name} is '${actual_arch}', expected '${oci_arch}'. Removing ${image_file_path}" >&2
        rm -f "${image_file_path}"
        exit 1
    fi

    cp "${image_file_path}" "${dst_image_file_path}"
) 3>"${image_file_path}.lock"