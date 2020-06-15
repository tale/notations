TARGET = iphone:clang::11.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk
BUNDLE_NAME = NotationsPrefs

NotationsPrefs_FILES = $(wildcard *.m) $(wildcard SkittyPrefs/*.m)
NotationsPrefs_INSTALL_PATH = /Library/PreferenceBundles
NotationsPrefs_FRAMEWORKS = UIKit
NotationsPrefs_PRIVATE_FRAMEWORKS = Preferences
NotationsPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/NotationsPrefs.plist$(ECHO_END)
