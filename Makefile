TARGET = iphone:clang:11.2:11.0
ARCHS = arm64
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Notations

notations_FILES = Tweak.x $(wildcard *.m)
notations_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
