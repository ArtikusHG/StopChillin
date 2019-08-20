DEBUG = 0
FINALPACKAGE = 1

ARCHS = armv7 arm64 arm64e
include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = stopchillinprefs
stopchillinprefs_FILES = SCPRootListController.m SCPCountdownPicker.m
stopchillinprefs_INSTALL_PATH = /Library/PreferenceBundles
stopchillinprefs_FRAMEWORKS = UIKit
stopchillinprefs_PRIVATE_FRAMEWORKS = Preferences
stopchillinprefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/stopchillinprefs.plist$(ECHO_END)
