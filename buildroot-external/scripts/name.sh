#!/bin/bash

function lva_os_image_name() {
    echo "${BINARIES_DIR}/${LVA_OS_ID}_${BOARD_ID}-$(lva_os_version).${1}"
}

function lva_os_image_basename() {
    echo "${BINARIES_DIR}/${LVA_OS_ID}_${BOARD_ID}-$(lva_os_version)"
}

function lva_os_rauc_compatible() {
    echo "${LVA_OS_ID}-${BOARD_ID}"
}

function lva_os_version() {
    if [ -z "${VERSION_SUFFIX}" ]; then
        echo "${VERSION_MAJOR}.${VERSION_MINOR}"
    else
        echo "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_SUFFIX}"
    fi
}

function path_boot_dir() {
    echo "${BINARIES_DIR}/boot"
}

function path_data_img() {
    echo "${BINARIES_DIR}/data.ext4"
}

function path_rootfs_img() {
    echo "${BINARIES_DIR}/rootfs.erofs"
}