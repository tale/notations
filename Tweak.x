#import "Tweak.h"
#import "NTSManager.h"
#import "NTSNote.h"
#import "NTSWindow.h"

static NSString *bundleIdentifier = @"dev.renaitare.notations";

static NSMutableDictionary *preferences;
static BOOL enabled;
static NSInteger gesture;

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

- (void)viewDidLoad {
	%orig;

	if (enabled) {
		if (gesture == 2) {
			UITapGestureRecognizer *notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:[NTSManager sharedInstance] action:@selector(toggleNotes)];
			notationsGesture.numberOfTapsRequired = 2;
			[self.view addGestureRecognizer:notationsGesture];
		} else if (gesture == 3) {
			UITapGestureRecognizer *notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:[NTSManager sharedInstance] action:@selector(toggleNotes)];
			notationsGesture.numberOfTapsRequired = 3;
			[self.view addGestureRecognizer:notationsGesture];
		}

		[[NTSManager sharedInstance] initView];

		UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(createNote:)];
		[[NTSManager sharedInstance].view addGestureRecognizer:pressRecognizer];

		[[NTSManager sharedInstance] loadNotes];
		[[NTSManager sharedInstance] updateNotes];
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

- (instancetype)initWithFrame:(CGRect)frame {
	self = %orig;

	if (gesture == 0) {
		UITapGestureRecognizer *notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:[NTSManager sharedInstance] action:@selector(toggleNotes)];
		notationsGesture.numberOfTapsRequired = 2;
		[self addGestureRecognizer:notationsGesture];
	} else if (gesture == 1) {
		UILongPressGestureRecognizer *notationsGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:[NTSManager sharedInstance] action:@selector(toggleNotes)];
		[self addGestureRecognizer:notationsGesture];
	}

	return self;
}

%end

%hook SBMainDisplaySceneLayoutStatusBarView

- (void)_addStatusBarIfNeeded {
	%orig;

	UIView *statusBar = [self valueForKey:@"_statusBar"];

	if (gesture == 0) {
		UITapGestureRecognizer *notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:[NTSManager sharedInstance] action:@selector(toggleNotes)];
		notationsGesture.numberOfTapsRequired = 2;
		[statusBar addGestureRecognizer:notationsGesture];
	} else if (gesture == 1) {
		UILongPressGestureRecognizer *notationsGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:[NTSManager sharedInstance] action:@selector(toggleNotes)];
		[self addGestureRecognizer:notationsGesture];
		[statusBar addGestureRecognizer:notationsGesture];
	}
}

%end

%ctor {
	updatePreferences();
}