#import "NTSRootListController.h"
#import <Preferences/PSSpecifier.h>

@implementation NTSRootListController

- (instancetype)init {
	self = [super init];

	if (self) {
		NSMutableDictionary *preferences;
		CFArrayRef preferencesKeyList = CFPreferencesCopyKeyList(CFSTR("me.renai.notations"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
		if (preferencesKeyList) {
			preferences = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(preferencesKeyList, CFSTR("me.renai.notations"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
			CFRelease(preferencesKeyList);
		} else {
			preferences = nil;
		}

		if (preferences == nil) {
			preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", @"me.renai.notations"]];
		}

		UISwitch *toggleSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
		[toggleSwitch setOn:[([preferences objectForKey:@"enabled"] ?: @(YES)) boolValue] animated:NO];
		[toggleSwitch addTarget:self action:@selector(updateSwitch:) forControlEvents:UIControlEventTouchUpInside];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toggleSwitch];
	}

	return self;
}

- (void)updateSwitch:(UISwitch *)sender {
    UISwitch *toggleSwitch = (UISwitch *)sender;

	CFPreferencesSetValue(CFSTR("enabled"), CFBridgingRetain([NSNumber numberWithBool:[toggleSwitch isOn]]), CFSTR("me.renai.notations"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("me.renai.notations/reload"), NULL, NULL, YES);
}

- (NSMutableArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
		self.required = (!self.required) ? [NSMutableDictionary new] : self.required;

		for (PSSpecifier *specifier in _specifiers) {
			if ([specifier propertyForKey:@"requires"]) {
				[self.required setObject:@0 forKey:[specifier propertyForKey:@"requires"]];
			}
		}

		for (PSSpecifier *specifier in _specifiers) {
			if ([self.required objectForKey:[specifier propertyForKey:@"key"]]) {
				[self.required setObject:[self readPreferenceValue:specifier] forKey:[specifier propertyForKey:@"key"]];
			}
		}
	}

	return _specifiers;
}

- (CGFloat)tableView:(UITableView *)view heightForRowAtIndexPath:(NSIndexPath *)path {
	PSSpecifier *specifier = [self specifierAtIndexPath:path];
	if ([specifier propertyForKey:@"requires"]) {
		if (![[self.required objectForKey:[specifier propertyForKey:@"requires"]] boolValue]) {
			return 0.01;
		}
	}

	return [super tableView:view heightForRowAtIndexPath:path];
}

- (void)tableView:(UITableView *)view willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)path {
	cell.clipsToBounds = YES;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];
	if ([specifier propertyForKey:@"key"] && [self.required objectForKey:[specifier propertyForKey:@"key"]]) {
		[self.required setObject:value forKey:[specifier propertyForKey:@"key"]];
		[[self valueForKey:@"_table"] beginUpdates];
		[[self valueForKey:@"_table"] endUpdates];
	}
}

- (void)submitIssue {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/Renaitare/Notations/issues/new"] options:@{} completionHandler:nil];
}

- (void)donate {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://ko-fi.com/renai"] options:@{} completionHandler:nil];
}

@end
