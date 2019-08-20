DEBUG = 0
FINALPACKAGE = 1

THEOS_DEVICE_IP = 192.168.0.87
ARCHS = armv7 arm64 arm64e
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = StopChillin
StopChillin_FILES = Tweak.xm
StopChillin_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += stopchillinprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
