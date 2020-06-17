#import "Notations.h"
#import "Manager/NTSManager.h"
#import "Objects/NTSNote.h"
#import "UI/Window/NTSWindow.h"
#import "Listener/NTSListener.h"

static NSString *bundleIdentifier = @"me.renai.notations";

static NSMutableDictionary *preferences;
static NSMutableArray *viewUpdateQueue;

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
	if (![viewUpdateQueue containsObject:self]) {
		[viewUpdateQueue addObject:self];
	}
}

%new
- (void)updateNotations {
	if (self.notationsGesture) [self.view removeGestureRecognizer:self.notationsGesture];
		if ([NTSManager sharedInstance].gesture == 2) {
			self.notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNotesShown)];
			((UITapGestureRecognizer *)self.notationsGesture).numberOfTapsRequired = 2;
			[self.view addGestureRecognizer:self.notationsGesture];
		} else if ([NTSManager sharedInstance].gesture == 3) {
			self.notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNotesShown)];
			((UITapGestureRecognizer *)self.notationsGesture).numberOfTapsRequired = 3;
			[self.view addGestureRecognizer:self.notationsGesture];
		}
}

%new
- (void)toggleNotesShown {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("me.renai.notations/toggle"), NULL, NULL, true);
}

%end

// Status bar gestures
%hook UIStatusBarWindow
%property (nonatomic, retain) UIGestureRecognizer *notationsGesture;

- (instancetype)initWithFrame:(CGRect)frame {
	self = %orig;
	[self updateNotations];
	if (![viewUpdateQueue containsObject:self]) {
		[viewUpdateQueue addObject:self];
	}
	return self;
}

%new
- (void)updateNotations {
	if (self.notationsGesture) [self removeGestureRecognizer:self.notationsGesture];
		if ([NTSManager sharedInstance].gesture == 0) {
			self.notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNotesShown)];
			((UITapGestureRecognizer *)self.notationsGesture).numberOfTapsRequired = 2;
			[self addGestureRecognizer:self.notationsGesture];
		} else if ([NTSManager sharedInstance].gesture == 1) {
			self.notationsGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressStatusBar:)];
			[self addGestureRecognizer:self.notationsGesture];
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
	CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("me.renai.notations/toggle"), NULL, NULL, true);
}

%end

%group iOS13StatusBar

%hook SBMainDisplaySceneLayoutStatusBarView
%property (nonatomic, retain) UIGestureRecognizer *notationsGesture;

- (void)_addStatusBarIfNeeded {
	%orig;
	[self updateNotations];
	if (![viewUpdateQueue containsObject:self]) {
		[viewUpdateQueue addObject:self];
	}
}

%new
- (void)updateNotations {
	UIView *statusBar = [self valueForKey:@"_statusBar"];
	if (self.notationsGesture) [statusBar removeGestureRecognizer:self.notationsGesture];
		if ([NTSManager sharedInstance].gesture == 0) {
			self.notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleNotesShown)];
			((UITapGestureRecognizer *)self.notationsGesture).numberOfTapsRequired = 2;
			[statusBar addGestureRecognizer:self.notationsGesture];
		} else if ([NTSManager sharedInstance].gesture == 1) {
			self.notationsGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressStatusBar:)];
			[statusBar addGestureRecognizer:self.notationsGesture];
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
	CFNotificationCenterPostNotification(CFNotificationCenterGetDistributedCenter(), CFSTR("me.renai.notations/toggle"), NULL, NULL, true);
}

%end

%end

static void NTSToggleNotes() {
	if (![[[NSBundle mainBundle] bundleIdentifier] isEqual:@"com.apple.springboard"]) return;
	[[NTSManager sharedInstance] toggleNotesShown];
}

static void NTSPreferencesUpdate() {
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

	[NTSManager sharedInstance].enabled = [([preferences objectForKey:@"enabled"] ?: @(YES)) boolValue];
	[NTSManager sharedInstance].gesture = [([preferences objectForKey:@"gesture"] ?: @(0)) integerValue];
	[NTSManager sharedInstance].colorStyle = [([preferences objectForKey:@"style"] ?: @(0)) integerValue];
	[NTSManager sharedInstance].textAlignment = [([preferences objectForKey:@"alignment"] ?: @(1)) integerValue];
	[NTSManager sharedInstance].isCustomText = [([preferences objectForKey:@"isCustomText"] ?: @(NO)) boolValue];

	if ([NTSManager sharedInstance].isCustomText) {
		[NTSManager sharedInstance].textSize = [([preferences objectForKey:@"customText"] ?: @([UIFont systemFontSize])) integerValue];
	} else {
		[NTSManager sharedInstance].textSize = [UIFont systemFontSize];
	}

	for (SBMainDisplaySceneLayoutStatusBarView *view in viewUpdateQueue) {
		if ([view respondsToSelector:@selector(updateNotations)]) [view updateNotations];
	}
}

%ctor {
 	NSArray *arguments = [[NSProcessInfo processInfo] arguments];
 	if (arguments != nil && arguments.count != 0) {
 		NSString *executablePath = arguments[0];
 		BOOL isSpringBoard = [[executablePath lastPathComponent] isEqualToString:@"SpringBoard"];
 		BOOL isApplication = [executablePath rangeOfString:@"/Application"].location != NSNotFound;

		if (isSpringBoard || isApplication) {
			if (%c(UIStatusBarManager)) {
				%init(iOS13StatusBar)
			}

			%init;
			viewUpdateQueue = [NSMutableArray new];

			NTSPreferencesUpdate();

			CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) NTSPreferencesUpdate, CFSTR("me.renai.notations/reload"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

			CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), NULL, (CFNotificationCallback) NTSToggleNotes, CFSTR("me.renai.notations/toggle"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

			if (isSpringBoard) {
				dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
				id la = %c(LAActivator);
				if (la) {
					[[la sharedInstance] registerListener:[NTSListener new] forName:@"me.renai.notations/toggle"];
				}
			}
		}
	}
}
