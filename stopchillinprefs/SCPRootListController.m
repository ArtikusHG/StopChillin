#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.artikus.stopchillinprefs.plist"

#include <UIKit/UIKit.h>
#include "SCPRootListController.h"

@implementation SCPRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}
	return _specifiers;
}

- (void)testNotif {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.artikus.stopchillin.testnotif"), NULL, NULL, YES);
}

- (void)twitter {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/ArtikusHG"] options:@{} completionHandler:nil];
}

- (void)github {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/ArtikusHG"] options:@{} completionHandler:nil];
}

- (void)soundcloud {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://soundcloud.com/ArtikusHG"] options:@{} completionHandler:nil];
}

// thanks Julioverne for opensourcing his tweaks :p
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSMutableDictionary dictionary];
	[dict setObject:value forKey:[specifier propertyForKey:@"key"]];
	[dict writeToFile:@PLIST_PATH_Settings atomically:YES];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.artikus.stopchillin.changed"), NULL, NULL, YES);
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSMutableDictionary dictionary];
	return dict[[specifier propertyForKey:@"key"]]?:NO;
}

@end
