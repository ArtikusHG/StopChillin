#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.artikus.stopchillinprefs.plist"


@interface JBBulletinManager : NSObject
+ (id)sharedInstance;
- (id)showBulletinWithTitle:(NSString *)title message:(NSString *)message bundleID:(NSString *)bundleID;
- (id)showBulletinWithTitle:(NSString *)title message:(NSString *)message overrideBundleImage:(UIImage *)overrideBundleImage;
- (id)showBulletinWithTitle:(NSString *)title message:(NSString *)message overrideBundleImage:(UIImage *)overrideBundleImage soundPath:(NSString *)soundPath;
@end

@interface SpringBoard : UIApplication
- (void)cancelUsageNotificationCountdown;
- (void)startUsageNotificationCountdown;
- (void)showUsageNotification:(BOOL)isTest;
@end

NSDictionary *dict;

NSString *usageTitle;
NSString *usageMessage;
NSString *customHourString;
NSString *customHoursString;
NSString *customMinuteString;
NSString *customMinutesString;
NSString *customAndString;

BOOL enabled;
double countdown;

BOOL isCountdownRunning;



%group StopChillinMethods

%hook SpringBoard

%new
- (void)startUsageNotificationCountdown {
  if (enabled && countdown > 0 && !isCountdownRunning) {
    isCountdownRunning = YES;
    //[[[UIAlertView alloc] initWithTitle:@"A" message:@"A" delegate:nil cancelButtonTitle:@"a" otherButtonTitles:nil] show];
    [self performSelector:@selector(showUsageNotification:) withObject:self afterDelay:countdown];
  }
}

%new
- (void)cancelUsageNotificationCountdown {
  isCountdownRunning = NO;
  [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showUsageNotification:) object:self];
}

%new
- (void)showUsageNotification:(BOOL)isTest {
  if (!enabled && !isTest) return;
  int minutes = round(countdown) / 60;
  int hours = round(minutes / 60);
  NSString *minutesString = customMinutesString;
  NSString *hoursString = customHoursString;
  if (minutes == 1) minutesString = customMinuteString;
  if (hours == 1) hoursString = customHourString;
  NSMutableString *usageString = [[NSMutableString alloc] init];
  if (hours != 0) {
    [usageString appendString:[NSString stringWithFormat:@"%d %@", hours, hoursString]];
    minutes = minutes - (hours * 60); // in case we have 1 hour 30 minutes so we dont get 1 hour 90 minutes; i minus the amount of minutes in the hour from the amount of actual minutes, so from for example 1 hour 90 minutes it turns into 1 hour 30 minutes
    if(minutes == 1) minutesString = customMinuteString;
    if(minutes != 0) {
      [usageString appendString:[NSString stringWithFormat:@" %@ %d %@", customAndString, minutes, minutesString]];
    }
  } else if (minutes != 0) {
    [usageString appendString:[NSString stringWithFormat:@"%d %@", minutes, minutesString]];
  }
  [[objc_getClass("JBBulletinManager") sharedInstance] showBulletinWithTitle:usageTitle message:[NSString stringWithFormat:usageMessage, usageString] overrideBundleImage:nil];
  if(!isTest) {
    isCountdownRunning = NO;
    [self performSelector:@selector(showUsageNotification:) withObject:self afterDelay:countdown];
    isCountdownRunning = YES;
  }
}

%end



%end

%group StopChillinCountdown

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
  %orig;
  [self startUsageNotificationCountdown];
}

%end

%hook SBLockScreenManager

- (BOOL)_lockUI {
  [(SpringBoard *)[objc_getClass("SpringBoard") sharedApplication] cancelUsageNotificationCountdown];
  return %orig;
}

- (void)lockUIFromSource:(int)source withOptions:(id)options {
  %orig;
  [(SpringBoard *)[objc_getClass("SpringBoard") sharedApplication] cancelUsageNotificationCountdown];
}

%end

%hook SBBacklightController

- (void)turnOnScreenFullyWithBacklightSource:(long long)source {
  //[[[UIAlertView alloc] initWithTitle:@"A" message:[NSString stringWithFormat:@"%lld",source] delegate:nil cancelButtonTitle:@"a" otherButtonTitles:nil] show];
  %orig;
  // 26 - source of screenshots on newer ios version (afaik); hope this shitty hotfix i made right before release works... please
  if (source != 26) [(SpringBoard *)[objc_getClass("SpringBoard") sharedApplication] startUsageNotificationCountdown];
}

%end

%end



static void LoadPreferences() {
  dict = nil;
  dict = [[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSMutableDictionary dictionary];

  if([(NSString *)dict[@"kCustomTitle"] length] > 0) usageTitle = dict[@"kCustomTitle"];
  else usageTitle = @"Put your phone down";
  if([(NSString *)dict[@"kCustomMessage"] length] > 0) usageMessage = dict[@"kCustomMessage"];
  else usageMessage = @"You've been using your phone for %@ continuously. Go watch the world, don't waste your time.";

  if([(NSString *)dict[@"kCustomHour"] length] > 0) customHourString = dict[@"kCustomHour"];
  else customHourString = @"hour";
  if([(NSString *)dict[@"kCustomHours"] length] > 0) customHoursString = dict[@"kCustomHours"];
  else customHoursString = @"hours";
  if([(NSString *)dict[@"kCustomMinute"] length] > 0) customMinuteString = dict[@"kCustomMinute"];
  else customMinuteString = @"minute";
  if([(NSString *)dict[@"kCustomMinutes"] length] > 0) customMinutesString = dict[@"kCustomMinutes"];
  else customMinutesString = @"minutes";

  if([(NSString *)dict[@"kCustomAnd"] length] > 0) customAndString = dict[@"kCustomAnd"];
  else customAndString = @"and";

  enabled = [dict[@"kEnabled"] boolValue]?:NO;
  countdown = [dict[@"kNotificationInterval"] doubleValue]?:0;
  [(SpringBoard *)[objc_getClass("SpringBoard") sharedApplication] cancelUsageNotificationCountdown];
  if (enabled) [(SpringBoard *)[objc_getClass("SpringBoard") sharedApplication] startUsageNotificationCountdown];
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  [[objc_getClass("JBBulletinManager") sharedInstance] showBulletinWithTitle:@"Value saved" message:@"If you're reading this, your custom time has been saved. Long story short, I couldn't understand why sometimes the preferences don't save, so I made this notification... Also, lock you device and unlock it again to start the countdown with the new time." bundleID:@"com.apple.Preferences"];
  LoadPreferences();
}

static void ShowTestNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  [(SpringBoard *)[objc_getClass("SpringBoard") sharedApplication] showUsageNotification:YES];
}

%ctor {
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR("com.artikus.stopchillin.changed"), NULL, 0);
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, ShowTestNotification, CFSTR("com.artikus.stopchillin.testnotif"), NULL, 0);
  LoadPreferences();
  %init(StopChillinMethods); // we init springboard methods anyway cause test notif and then init countdown if enabled
  if (enabled) %init(StopChillinCountdown);
}
