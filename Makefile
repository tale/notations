INSTALL_TARGET_PROCESSES = SpringBoard
ARCHS = arm64 arm64e
TARGET = iphone:clang::13.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Notations

Notations_FILES = Tweak.x $(wildcard *.m)
Notations_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk
