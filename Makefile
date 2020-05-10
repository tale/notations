INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e
TARGET = iphone:clang::

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Notations

Notations_FILES = Tweak.x $(wildcard Notations/*/*.m)  $(wildcard Notations/*/*/*.m)
Notations_CFLAGS = -fobjc-arc -IHeaders -Wno-deprecated-declarations -Wno-unguarded-availability-new

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
