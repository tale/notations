#include "NTSRootListController.h"

@implementation NTSRootListController

-  (instancetype)init {
	self = [super init];

	if (self) {
		self.toggle = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 51, 31)];
		[self.toggle setOn:YES animated:YES];
		[self.toggle addTarget:self action:@selector(toggleState) forControlEvents:UIControlEventValueChanged];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.toggle];
	}

	return self;
}

- (void)toggleState {
	[[NSUserDefaults standardUserDefaults] setBool:self.toggle forKey:@"notations_enabled"];
	  	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge CFStringRef)@"me.renai.notations.prefsupdate", NULL, NULL, YES);
}

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

@end
