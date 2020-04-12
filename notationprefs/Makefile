include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = NotationPrefs

NotationPrefs_FILES = NTSRootListController.m
NotationPrefs_INSTALL_PATH = /Library/PreferenceBundles
NotationPrefs_FRAMEWORKS = UIKit
NotationPrefs_PRIVATE_FRAMEWORKS = Preferences
NotationPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/NotationPrefs.plist$(ECHO_END)
