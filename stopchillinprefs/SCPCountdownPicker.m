#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.artikus.stopchillinprefs.plist"

#include <Preferences/PSViewController.h>
#include <objc/runtime.h>
#include "SCPCountdownPicker.h"

@interface JBBulletinManager : NSObject
+ (id)sharedInstance;
- (id)showBulletinWithTitle:(NSString *)title message:(NSString *)message overrideBundleImage:(UIImage *)overrideBundleImage;
@end

@implementation SCPCountdownPicker

@synthesize datePicker;

- (void)viewDidLoad {
  [super viewDidLoad];
  UIView *datePickerView = [[UIView alloc] initWithFrame:self.view.bounds];
  datePickerView.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1];
  if(![[NSFileManager defaultManager] fileExistsAtPath:@PLIST_PATH_Settings isDirectory:nil]) [[NSFileManager defaultManager] createFileAtPath:@PLIST_PATH_Settings contents:nil attributes:nil];
  datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height / 2 - 100, [UIScreen mainScreen].bounds.size.width, 200)];
  datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
  datePicker.countDownDuration = (double)[self getCurrentInterval];
  [datePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
  [datePickerView addSubview:datePicker];
  if([self respondsToSelector:@selector(setView:)]) [self setView:datePickerView];
}

- (void)dateChanged {
  //[[[UIAlertView alloc] initWithTitle:@"a" message:[NSString stringWithFormat:@"%f",datePicker.countDownDuration] delegate:nil cancelButtonTitle:@"a" otherButtonTitles:nil] show];
  NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSMutableDictionary dictionary];
  [dict setValue:[[NSNumber alloc] initWithDouble:datePicker.countDownDuration] forKey:@"kNotificationInterval"];
  [dict writeToFile:@PLIST_PATH_Settings atomically:YES];
  CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.artikus.stopchillin.changed"), NULL, NULL, YES);
}

- (double)getCurrentInterval {
	NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSMutableDictionary dictionary];
	return [dict[@"kNotificationInterval"] doubleValue]?:0;
}

@end
