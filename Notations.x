#import "./Notations.h"
#import "./src/Objects/RINotationsManager.h"
#import "./src/Objects/RINotationsNote.h"
#import "./src/Objects/RINotationsActivatorListener.h"
#import "./src/UI/RINotationsWindow.h"

static NSDictionary *preferences;
static NSMutableArray *viewsToUpdate;

static void reloadNotationsPreferences() {
	CFPreferencesAppSynchronize((CFStringRef)kIdentifier);

	if ([NSHomeDirectory()isEqualToString:@"/var/mobile"]) {
		CFArrayRef keyList = CFPreferencesCopyKeyList((CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);

		if (keyList) {
			preferences = (NSDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, (CFStringRef)kIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));

			if (!preferences) {
				preferences = [NSDictionary new];
			}

			CFRelease(keyList);
		}
	} else {
		preferences = [NSDictionary dictionaryWithContentsOfFile:kSettingsPath];
	}

	[RINotationsManager sharedInstance].enabled = [preferences objectForKey:@"enabled"] ? [[preferences valueForKey:@"enabled"] boolValue] : YES;
	[RINotationsManager sharedInstance].gesture = [preferences objectForKey:@"gesture"] ? [[preferences valueForKey:@"gesture"] intValue] : 0;
	[RINotationsManager sharedInstance].style = [preferences objectForKey:@"style"] ? [[preferences valueForKey:@"style"] intValue] : 0;
	[RINotationsManager sharedInstance].alignment = [preferences objectForKey:@"alignment"] ? [[preferences valueForKey:@"alignment"] intValue] : 0;

	for (SBMainDisplaySceneLayoutStatusBarView *view in viewsToUpdate) {
		if ([view respondsToSelector:@selector(updateNotations)]) {
			[view updateNotations];
		}
	}
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	reloadNotationsPreferences();
}

%hook SBLockHardwareButton

- (void)singlePress:(id)sender {
	if ([RINotationsManager sharedInstance].visible) {
		[[RINotationsManager sharedInstance] hideNotes];
		return;
	}

	%orig;
}

%end

%hook SBHomeHardwareButton

- (void)singlePressUp:(id)sender {
	if ([RINotationsManager sharedInstance].visible) {
		[[RINotationsManager sharedInstance] hideNotes];
		return;
	}

	%orig;
}

%end

%hook SBFluidSwitcherViewController

- (void)viewWillAppear:(BOOL)sender {
	%orig;
	[[RINotationsManager sharedInstance] hideNotes];
}

%end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)sender {
	%orig;
	[[RINotationsManager sharedInstance] loadView];
	[[RINotationsManager sharedInstance] loadNotes];
}

%end

%hook SBHomeScreenViewController
%property (nonatomic, retain) UIGestureRecognizer *notationsGesture;

- (void)viewDidLoad {
	%orig;
	[self updateNotations];
	if (![viewsToUpdate containsObject:self]) {
		[viewsToUpdate addObject:self];
	}
}

%new
- (void)updateNotations {
	if (self.notationsGesture) [self.view removeGestureRecognizer:self.notationsGesture];
	if ([RINotationsManager sharedInstance].enabled) {
		if ([RINotationsManager sharedInstance].gesture == 2) {
			self.notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNotesShown)];
			((UITapGestureRecognizer *)self.notationsGesture).numberOfTapsRequired = 2;
			[self.view addGestureRecognizer:self.notationsGesture];
		} else if ([RINotationsManager sharedInstance].gesture == 3) {
			self.notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNotesShown)];
			((UITapGestureRecognizer *)self.notationsGesture).numberOfTapsRequired = 3;
			[self.view addGestureRecognizer:self.notationsGesture];
		}
	}
}

%new
- (void)toggleNotesShown {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), (CFStringRef)[NSString stringWithFormat:@"%@/togglenotes", kTweakIdentifier], nil, nil, true);
}

%end

%hook UIStatusBarWindow
%property (nonatomic, retain) UIGestureRecognizer *notationsGesture;

- (instancetype)initWithFrame:(CGRect)frame {
	self = %orig;
	[self updateNotations];
	if (![viewsToUpdate containsObject:self]) {
		[viewsToUpdate addObject:self];
	}
	return self;
}

%new
- (void)updateNotations {
	if (self.notationsGesture) [self removeGestureRecognizer:self.notationsGesture];
	if ([RINotationsManager sharedInstance].enabled) {
		if ([RINotationsManager sharedInstance].gesture == 0) {
			self.notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNotesShown)];
			((UITapGestureRecognizer *)self.notationsGesture).numberOfTapsRequired = 2;
			[self addGestureRecognizer:self.notationsGesture];
		} else if ([RINotationsManager sharedInstance].gesture == 1) {
			self.notationsGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressStatusBar:)];
			[self addGestureRecognizer:self.notationsGesture];
		}
	}
}

%new
- (void)longPressStatusBar:(UILongPressGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateBegan) {
		[self toggleNotesShown];
	}
}

%new
- (void)toggleNotesShown {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), (CFStringRef)[NSString stringWithFormat:@"%@/togglenotes", kTweakIdentifier], nil, nil, true);
}

%end

%group iOS13StatusBar

%hook SBMainDisplaySceneLayoutStatusBarView
%property (nonatomic, retain) UIGestureRecognizer *notationsGesture;

- (void)_addStatusBarIfNeeded {
	%orig;
	[self updateNotations];
	if (![viewsToUpdate containsObject:self]) {
		[viewsToUpdate addObject:self];
	}
}

%new
- (void)updateNotations {
	UIView *statusBar = [self valueForKey:@"_statusBar"];
	if (self.notationsGesture) [statusBar removeGestureRecognizer:self.notationsGesture];
	if ([RINotationsManager sharedInstance].enabled) {
		if ([RINotationsManager sharedInstance].gesture == 0) {
			self.notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNotesShown)];
			((UITapGestureRecognizer *)self.notationsGesture).numberOfTapsRequired = 2;
			[statusBar addGestureRecognizer:self.notationsGesture];
		} else if ([RINotationsManager sharedInstance].gesture == 1) {
			self.notationsGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressStatusBar:)];
			[statusBar addGestureRecognizer:self.notationsGesture];
		}
	}
}

%new
- (void)longPressStatusBar:(UILongPressGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateBegan) {
		[self toggleNotesShown];
	}
}

%new
- (void)toggleNotesShown {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), (CFStringRef)[NSString stringWithFormat:@"%@/togglenotes", kTweakIdentifier], nil, nil, true);
}

%end

%end

static void toggleNotes(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	if (![[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.springboard"]) {
		return;
	}
	[[RINotationsManager sharedInstance] toggleNotes];
}

%ctor {
 	NSArray *args = [[NSProcessInfo processInfo] arguments];
 	if (args != nil && args.count != 0) {
 		NSString *execPath = args[0];
 		BOOL isSpringBoard = [[execPath lastPathComponent] isEqualToString:@"SpringBoard"];
 		BOOL isApplication = [execPath rangeOfString:@"/Application"].location != NSNotFound;

		if (isSpringBoard || isApplication) {
			if (%c(UIStatusBarManager)) {
				%init(iOS13StatusBar)
			}

			%init;
			viewsToUpdate = [NSMutableArray new];
			reloadNotationsPreferences();

			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)PreferencesChangedCallback, kSettingsChangedNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

			CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, toggleNotes, kActivatorNotification, NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

			if (isSpringBoard) {
				dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
				id libActivator = %c(LAActivator);
				if (libActivator) {
					[[libActivator sharedInstance] registerListener:[RINotationsActivatorListener new] forName:@"me.renai.notations/togglenotes"];
				}
			}
		}
	}
}
