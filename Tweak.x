#import "Tweak.h"
#import "NTSManager.h"
#import "NTSNote.h"
#import "NTSWindow.h"

static NSString *bundleIdentifier = @"dev.renaitare.notations";

static NSMutableDictionary *preferences;
static BOOL enabled;
static NSInteger gesture;

static NSMutableArray *viewsToUpdate;

static void updatePreferences() {
	CFArrayRef preferencesKeyList = CFPreferencesCopyKeyList((CFStringRef)bundleIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (preferencesKeyList) {
		preferences = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(preferencesKeyList, (CFStringRef)bundleIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(preferencesKeyList);
	} else {
		preferences = nil;
	}

	if (preferences == nil) {
		preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@.plist", bundleIdentifier]];
	}

	enabled = [([preferences objectForKey:@"enabled"] ?: @(YES)) boolValue];
	gesture = [([preferences objectForKey:@"gesture"] ?: @(0)) integerValue];
	[NTSManager sharedInstance].colorStyle = [([preferences objectForKey:@"style"] ?: @(0)) integerValue];
	[NTSManager sharedInstance].useCustomTextSize = [([preferences objectForKey:@"useCustomTextSize"] ?: @(NO)) boolValue];
	[NTSManager sharedInstance].textAlignment = [([preferences objectForKey:@"textAlignment"] ?: @(0)) integerValue];

	if ([NTSManager sharedInstance].useCustomTextSize == YES) {
		[NTSManager sharedInstance].textSize = [([preferences objectForKey:@"customTextSize"] ?: @(14)) integerValue];
	} else {
		[NTSManager sharedInstance].textSize = [UIFont systemFontSize];
	}

	[[NTSManager sharedInstance] reloadNotes];

	// Update gestures
	// They're not all SBMainDisplaySceneLayoutStatusBarViews, that's just so we don't have to do an ugly cast.
	for (SBMainDisplaySceneLayoutStatusBarView *view in viewsToUpdate) {
		if ([view respondsToSelector:@selector(updateNotations)]) [view updateNotations];
	}
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	updatePreferences();
}

// Hide notes on power button press
%hook SBLockHardwareButton

- (void)singlePress:(id)arg1 {
	if ([NTSManager sharedInstance].windowVisible) {
		[[NTSManager sharedInstance] hideNotes];
		return;
	}
	%orig;
}

%end

// Hide notes on home button press
%hook SBHomeHardwareButton

- (void)singlePressUp:(id)arg1 {
	if ([NTSManager sharedInstance].windowVisible) {
		[[NTSManager sharedInstance] hideNotes];
		return;
	}
	%orig;
}

%end

// Hide notes when switcher opens
%hook SBFluidSwitcherViewController

- (void)viewWillAppear:(BOOL)arg1 {
	%orig;
	[[NTSManager sharedInstance] hideNotes];
}

%end

// Home screen gestures
%hook SBHomeScreenViewController
%property (nonatomic, retain) UIGestureRecognizer *notationsGesture;

- (void)viewDidLoad {
	%orig;

	[[NTSManager sharedInstance] initView];

	UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(createNote:)];
	[[NTSManager sharedInstance].view addGestureRecognizer:pressRecognizer];

	[[NTSManager sharedInstance] loadNotes];
	[[NTSManager sharedInstance] updateNotes];

	[self updateNotations];
	if (![viewsToUpdate containsObject:self]) {
		[viewsToUpdate addObject:self];
	}
}

%new
- (void)updateNotations {
	if (self.notationsGesture) [self.view removeGestureRecognizer:self.notationsGesture];
	if (enabled) {
		if (gesture == 2) {
			self.notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:[NTSManager sharedInstance] action:@selector(toggleNotes)];
			((UITapGestureRecognizer *)self.notationsGesture).numberOfTapsRequired = 2;
			[self.view addGestureRecognizer:self.notationsGesture];
		} else if (gesture == 3) {
			self.notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:[NTSManager sharedInstance] action:@selector(toggleNotes)];
			((UITapGestureRecognizer *)self.notationsGesture).numberOfTapsRequired = 3;
			[self.view addGestureRecognizer:self.notationsGesture];
		}
	}
}

%new
- (void)createNote:(UILongPressGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateBegan) {
		if ([NTSManager sharedInstance].windowVisible) {
			CGPoint position = [sender locationInView:self.view];
			[[NTSManager sharedInstance] createNote:position];
		}
	}
}

%end

// Status bar gestures
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
	if (enabled) {
		if (gesture == 0) {
			self.notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:[NTSManager sharedInstance] action:@selector(toggleNotes)];
			((UITapGestureRecognizer *)self.notationsGesture).numberOfTapsRequired = 2;
			[self addGestureRecognizer:self.notationsGesture];
		} else if (gesture == 1) {
			self.notationsGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressStatusBar:)];
			[self addGestureRecognizer:self.notationsGesture];
		}
	}
}

%new
- (void)longPressStatusBar:(UILongPressGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateBegan) {
		[[NTSManager sharedInstance] toggleNotes];
	}
}

%end

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
	if (enabled) {
		if (gesture == 0) {
			self.notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:[NTSManager sharedInstance] action:@selector(toggleNotes)];
			((UITapGestureRecognizer *)self.notationsGesture).numberOfTapsRequired = 2;
			[statusBar addGestureRecognizer:self.notationsGesture];
		} else if (gesture == 1) {
			self.notationsGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressStatusBar:)];
			[statusBar addGestureRecognizer:self.notationsGesture];
		}
	}
}

%new
- (void)longPressStatusBar:(UILongPressGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateBegan) {
		[[NTSManager sharedInstance] toggleNotes];
	}
}

%end

%ctor {
	viewsToUpdate = [NSMutableArray new];
	updatePreferences();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, (CFStringRef)[NSString stringWithFormat:@"%@.prefsupdate", bundleIdentifier], NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}