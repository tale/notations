#include "./RIRootListController.h"

NSUserDefaults *userDefaults;

@implementation RINotationsRootListController

- (instancetype)init {
	self = [super init];

	if (self) {
		UISwitch *toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
		[toggleSwitch setOn:yourpreferencesvalue animated:NO];
		[toggleSwitch addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];

		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toggleSwitch];

		userDefaults = [[NSUserDefaults alloc] _initWithSuiteName:"me.renai.notations" container:[NSURL URLWithString:@"/var/mobile"]];

        [userDefaults registerDefaults:@{enabledKey : @YES, gestureKey : [NSNumber numberWithInt:0], styleKey : [NSNumber numberWithInt:0], alignmentKey : [NSNumber numberWithInt:0]}];
	}

	return self;
}

- (void)updateSwitch:(UISwitch *)sender {
    UISwitch *toggleSwitch = (UISwitch *)sender;
    [userDefaults setObject:[NSNumber numberWithBool:[toggleSwitch isOn]] forKey:enabledKey];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.renai.notations.preferences/reload"), NULL, NULL, YES);
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

@end
