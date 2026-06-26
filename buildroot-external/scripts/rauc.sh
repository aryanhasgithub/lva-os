#!/bin/bash

function prepare_rauc_signing() {
    local key="/build/key.pem"
    local cert="/build/cert.pem"

    if [ ! -f "${key}" ]; then
        echo "Generating a self-signed certificate for development"
        "${BR2_EXTERNAL_LVA_OS_PATH}"/scripts/generate-signing-key.sh "${cert}" "${key}"
    fi
}

function write_rauc_config() {
    mkdir -p "${TARGET_DIR}/etc/rauc"

    local ota_compatible
    ota_compatible="$(lva_os_rauc_compatible)"
    export ota_compatible
    export BOOTLOADER PARTITION_TABLE_TYPE BOOT_SPL

    (
        "${HOST_DIR}/bin/tempio" \
            -template "${BR2_EXTERNAL_LVA_OS_PATH}/ota/system.conf.gptl"
    ) > "${TARGET_DIR}/etc/rauc/system.conf"
}

function install_rauc_certs() {
    local cert="/build/cert.pem"

    # TODO: split into dev-ca.pem / rel-ca.pem when release signing
    # infrastructure is in place
    cp "${BR2_EXTERNAL_LVA_OS_PATH}/ota/lva-os-ca.pem" "${TARGET_DIR}/etc/rauc/keyring.pem"

    # Add local self-signed certificate
    if ! openssl verify -CAfile "${BR2_EXTERNAL_LVA_OS_PATH}/ota/lva-os-ca.pem" -no-CApath "${cert}"; then
        echo "Adding self-signed certificate to keyring."
        openssl x509 -in "${cert}" -text >> "${TARGET_DIR}/etc/rauc/keyring.pem"
    fi
}

function install_bootloader_config() {
    if [ "${BOOTLOADER}" == "uboot" ]; then
        echo -e "/dev/disk/by-partlabel/lva-os-bootstate\t0x0000\t${BOOT_ENV_SIZE}" \
            > "${TARGET_DIR}/etc/fw_env.config"
    fi

    # Fix MBR
    if [ "${PARTITION_TABLE_TYPE}" == "mbr" ]; then
        mkdir -p "${TARGET_DIR}/usr/lib/udev/rules.d"
        cp -f "${BR2_EXTERNAL_LVA_OS_PATH}/bootloader/mbr-part.rules" \
            "${TARGET_DIR}/usr/lib/udev/rules.d/"
    fi
}