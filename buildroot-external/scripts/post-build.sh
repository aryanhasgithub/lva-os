#!/bin/bash
# shellcheck disable=SC1090,SC1091
set -e

SCRIPT_DIR=${BR2_EXTERNAL_LVA_OS_PATH}/scripts
BOARD_DIR=${2}

. "${BR2_EXTERNAL_LVA_OS_PATH}/meta"
. "${BOARD_DIR}/meta"
. "${SCRIPT_DIR}/rootfs-layer.sh"
. "${SCRIPT_DIR}/name.sh"
. "${SCRIPT_DIR}/rauc.sh"

# LVA-OS tasks
fix_rootfs
install_tini_docker
setup_localtime
setup_vconsole

# Write os-release
(
    echo "NAME=\"LVA-OS\""
    echo "VERSION=\"$(lva_os_version) (${BOARD_NAME})\""
    echo "ID=lva-os"
    echo "VERSION_ID=$(lva_os_version)"
    echo "PRETTY_NAME=\"LVA-OS $(lva_os_version)\""
    echo "HOME_URL=https://github.com/aryanhasgithub/lva-os"
    echo "VARIANT=\"LVA-OS ${BOARD_NAME}\""
    echo "BOARD_ID=${BOARD_ID}"
) > "${TARGET_DIR}/usr/lib/os-release"

# Write machine-info
(
    echo "CHASSIS=${CHASSIS}"
    echo "DEPLOYMENT=${DEPLOYMENT}"
) > "${TARGET_DIR}/etc/machine-info"

# Setup RAUC
prepare_rauc_signing
write_rauc_config
install_rauc_certs
install_bootloader_config

# Fix overlay presets
"${HOST_DIR}/bin/systemctl" --root="${TARGET_DIR}" preset-all