#import "Tweak.h"
#import "Notations/Manager/NTSManager.h"
#import "Notations/Objects/NTSNote.h"
#import "Notations/UI/Window/NTSWindow.h"
#import "Notations/Listener/NTSListener.h"

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

// Initialize notes view
%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)arg1 {
	%orig;
	[[NTSManager sharedInstance] loadView];
	[[NTSManager sharedInstance] loadNotes];
}

%end

// Home screen gestures
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
	if (enabled) {
		if (gesture == 2) {
			self.notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNotesShown)];
			((UITapGestureRecognizer *)self.notationsGesture).numberOfTapsRequired = 2;
			[self.view addGestureRecognizer:self.notationsGesture];
		} else if (gesture == 3) {
			self.notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNotesShown)];
			((UITapGestureRecognizer *)self.notationsGesture).numberOfTapsRequired = 3;
			[self.view addGestureRecognizer:self.notationsGesture];
		}
	}
}

%new
- (void)toggleNotesShown {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), (CFStringRef)[NSString stringWithFormat:@"%@.togglenotes", bundleIdentifier], nil, nil, true);
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
			self.notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNotesShown)];
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
		[self toggleNotesShown];
	}
}

%new
- (void)toggleNotesShown {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), (CFStringRef)[NSString stringWithFormat:@"%@.togglenotes", bundleIdentifier], nil, nil, true);
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
	if (enabled) {
		if (gesture == 0) {
			self.notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNotesShown)];
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
		[self toggleNotesShown];
	}
}

%new
- (void)toggleNotesShown {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), (CFStringRef)[NSString stringWithFormat:@"%@.togglenotes", bundleIdentifier], nil, nil, true);
}

%end

%end

// Show notes window only on SpringBoard
static void toggleNotes(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	if (![[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.springboard"]) {
		return;
	}
	[[NTSManager sharedInstance] toggleNotesShown];
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
			updatePreferences();
			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, (CFStringRef)[NSString stringWithFormat:@"%@.prefsupdate", bundleIdentifier], NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
			CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, toggleNotes, (CFStringRef)[NSString stringWithFormat:@"%@.togglenotes", bundleIdentifier], NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

			if (isSpringBoard) {
				dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
				id la = %c(LAActivator);
				if (la) {
					[[la sharedInstance] registerListener:[NTSListener new] forName:@"dev.renaitare.notations.togglenotes"];
				}
			}
		}
	} 
}
