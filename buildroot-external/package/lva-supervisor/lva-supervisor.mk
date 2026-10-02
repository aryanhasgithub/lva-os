################################################################################
#
# lva-supervisor
#
################################################################################

LVA_SUPERVISOR_VERSION = 1.0.0
LVA_SUPERVISOR_LICENSE = Apache-2.0
LVA_SUPERVISOR_SITE = $(BR2_EXTERNAL_LVA_OS_PATH)/package/lva-supervisor
LVA_SUPERVISOR_SITE_METHOD = local
LVA_SUPERVISOR_VERSION_URL = "https://aryanhasgithub.github.io/lva-version/stable.json"

ifeq ($(BR2_aarch64),y)
LVA_SUPERVISOR_OCI_ARCH = arm64
else ifeq ($(BR2_x86_64),y)
LVA_SUPERVISOR_OCI_ARCH = amd64
endif

LVA_SUPERVISOR_CONTAINER_IMAGES_ARCH = lva-supervisor lva-cli lva-audio

define LVA_SUPERVISOR_CONFIGURE_CMDS
	curl -s $(LVA_SUPERVISOR_VERSION_URL) > $(@D)/version.json
endef

define LVA_SUPERVISOR_BUILD_CMDS
	mkdir -p $(@D)/images
	mkdir -p $(LVA_SUPERVISOR_DL_DIR)

	$(foreach image,$(LVA_SUPERVISOR_CONTAINER_IMAGES_ARCH),\
		$(BR2_EXTERNAL_LVA_OS_PATH)/package/lva-supervisor/fetch-container-image.sh \
			$(LVA_SUPERVISOR_OCI_ARCH) $(@D)/version.json $(image) "$(LVA_SUPERVISOR_DL_DIR)" "$(@D)/images"
	)
endef

LVA_SUPERVISOR_INSTALL_IMAGES = YES

define LVA_SUPERVISOR_INSTALL_IMAGES_CMDS
    $(BR2_EXTERNAL_LVA_OS_PATH)/package/lva-supervisor/create-data-partition.sh \
	    	"$(@D)" \
		    "$(BINARIES_DIR)" \
 		    "$(DOCKER_ENGINE_VERSION)"
endef

$(eval $(generic-package))
