INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e
TARGET = iphone:clang::11.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Notations

Notations_FILES = $(wildcard src/Notations/*.x) $(wildcard src/Notations/*/*.m) $(wildcard src/Notations/*/*/*.m)
Notations_CFLAGS = -fobjc-arc -IHeaders

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += src/Preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
