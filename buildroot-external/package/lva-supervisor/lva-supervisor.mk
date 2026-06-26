################################################################################
#
# lva-supervisor
#
################################################################################

LVA_SUPERVISOR_VERSION = 1.0.0
LVA_SUPERVISOR_LICENSE = Apache-2.0
LVA_SUPERVISOR_SITE = $(BR2_EXTERNAL_LVA_OS_PATH)/package/lva-supervisor
LVA_SUPERVISOR_SITE_METHOD = local

# Source the top-level meta file and echo each version variant
LVA_SUPERVISOR_CONTAINER_VERSION = $(shell . $(BR2_EXTERNAL_LVA_OS_PATH)/meta && echo $$LVA_SUPERVISOR_CONTAINER_VERSION)
LVA_CLI_CONTAINER_VERSION        = $(shell . $(BR2_EXTERNAL_LVA_OS_PATH)/meta && echo $$LVA_CLI_CONTAINER_VERSION)
LVA_AUDIO_CONTAINER_VERSION      = $(shell . $(BR2_EXTERNAL_LVA_OS_PATH)/meta && echo $$LVA_AUDIO_CONTAINER_VERSION)

ifeq ($(BR2_aarch64),y)
LVA_SUPERVISOR_OCI_ARCH = arm64
else ifeq ($(BR2_x86_64),y)
LVA_SUPERVISOR_OCI_ARCH = amd64
endif

LVA_SUPERVISOR_INSTALL_IMAGES = YES
define LVA_SUPERVISOR_INSTALL_IMAGES_CMDS
	mkdir -p $(@D)/images
	mkdir -p $(LVA_SUPERVISOR_DL_DIR)
	
	# Fetch lva-supervisor
	$(BR2_EXTERNAL_LVA_OS_PATH)/package/lva-supervisor/fetch-container-image.sh \
		"$(LVA_SUPERVISOR_CONTAINER_VERSION)" \
		"$(LVA_SUPERVISOR_OCI_ARCH)" \
		"$(LVA_SUPERVISOR_DL_DIR)" \
		"$(@D)/images" \
		lva-supervisor

	# Fetch lva-cli
	$(BR2_EXTERNAL_LVA_OS_PATH)/package/lva-supervisor/fetch-container-image.sh \
		"$(LVA_CLI_CONTAINER_VERSION)" \
		"$(LVA_SUPERVISOR_OCI_ARCH)" \
		"$(LVA_SUPERVISOR_DL_DIR)" \
		"$(@D)/images" \
		lva-cli

	# Fetch lva-audio
	$(BR2_EXTERNAL_LVA_OS_PATH)/package/lva-supervisor/fetch-container-image.sh \
		"$(LVA_AUDIO_CONTAINER_VERSION)" \
		"$(LVA_SUPERVISOR_OCI_ARCH)" \
		"$(LVA_SUPERVISOR_DL_DIR)" \
		"$(@D)/images" \
		lva-audio

	# Compile final block storage distribution arrays
	$(BR2_EXTERNAL_LVA_OS_PATH)/package/lva-supervisor/create-data-partition.sh \
		"$(@D)" \
		"$(BINARIES_DIR)" \
		"$(DOCKER_ENGINE_VERSION)"
endef

$(eval $(generic-package))
