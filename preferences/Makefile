include $(THEOS)/makefiles/common.mk

TARGET = iphone:clang::12.0
ARCHS = arm64 arm64e

BUNDLE_NAME = NotationsPrefs

NotationsPrefs_FILES = NTSRootListController.m $(wildcard SkittyPrefs/*.m)
NotationsPrefs_INSTALL_PATH = /Library/PreferenceBundles
NotationsPrefs_FRAMEWORKS = UIKit
NotationsPrefs_PRIVATE_FRAMEWORKS = Preferences
NotationsPrefs_CFLAGS = -fobjc-arc  -Wno-deprecated-declarations -Wno-unguarded-availability-new

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/NotationsPrefs.plist$(ECHO_END)
