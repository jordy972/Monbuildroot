#############################################################
#
# Chromium
#
#############################################################
CHROMIUM_SITE=rrepo://chromium
CHROMIUM_DEPENDENCIES=\
        bcm_bseav bcm_nexus bcm_common bcm_rockford \
        google_miniclient \
        libpng jpeg zlib freetype openssl expat \
        libcurl libxml2 libxslt fontconfig boost \
        cairo avahi libcap libnss host-ninja
# This will result in defining a meaningful APPLIBS_TOP
BCM_APPS_DIR=$(abspath $(@D))
CHROMIUM_INSTALL_STAGING=NO
CHROMIUM_INSTALL_TARGET=YES
define CHROMIUM_CONFIGURE_CMDS
        $(call BCM_COMMON_USE_BUILD_SYSTEM,$(@D))
endef
ifeq ($(BR2_CCACHE),y)
    CHROMIUM_CCACHE="WEBKITGL_USE_CCACHE=$(CCACHE)"
else
    CHROMIUM_CCACHE="WEBKITGL_USE_CCACHE="
endif
define CHROMIUM_BUILD_CMDS
        $(BCM_MAKE_ENV) $(MAKE) \
                $(BCM_MAKEFLAGS) \
                -C $(@D)/build \
                $(CHROMIUM_CCACHE) \
                PYTHONDONTOPTIMIZE="0" \
                SYSROOT=$(STAGING_DIR) \
                BUILD_DIR=$(BUILD_DIR)
endef
define CHROMIUM_BUILD_TEST_CMDS
        $(BCM_MAKE_ENV) $(MAKE) \
                $(BCM_MAKEFLAGS) \
                -C $(@D)/build \
                $(CHROMIUM_CCACHE) \
                PYTHONDONTOPTIMIZE="0" \
                SYSROOT=$(STAGING_DIR) \
                BUILD_DIR=$(BUILD_DIR) \
                unittests
endef
define CHROMIUM_INSTALL_TARGET_CMDS
        $(call BCM_COMMON_BUILD_EXTRACT_TARBALL, $(TARGET_DIR))
        if [ -e "$(TARGET_DIR)/usr/local/bin/webkitGl3/chrome-sandbox" ] ; \
                then \
                        chmod 4755 "$(TARGET_DIR)/usr/local/bin/webkitGl3/chrome-sandbox"; \
                fi
endef
# Since chromium needs dlna, etc. to be rebuilt and reinstalled to its
# lib directory. We need to remove the stamp to force the reinstall.
define CHROMIUM_DIRCLEAN_CMDS
        $(RM) $(@D)/common/*.stamp
endef
$(eval $(autotools-package))
