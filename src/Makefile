THEOS_DEVICE_IP = 192.168.2.211
THEOS_DEVICE_PORT = 22
TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = WeChat


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = noti
SUBSTRATE ?= yes
TweakName_USE_SUBSTRATE = $(SUBSTRATE)
$(TWEAK_NAME)_FILES = $(wildcard src/*.m) Tweak.xm
$(TWEAK_NAME)_FRAMEWORKS = UIKit AVFoundation CoreLocation
ADDITIONAL_CFLAGS += -Wno-deprecated-declarations

noti_CFLAGS = -fobjc-arc
src/SecureRequest.m_CFLAGS = -fobjc-arc
src/NotiPushConfig.m_CFLAGS = -fobjc-arc
src/NotiPushSettingTableViewController.m_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
