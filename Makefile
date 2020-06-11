ARCHS = arm64 arm64e
TARGET = iphone:clang::11.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Notations

Notations_FILES = Notations.x $(wildcard src/*/*.m)
Notations_CFLAGS = -fobjc-arc -IHeaders

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
