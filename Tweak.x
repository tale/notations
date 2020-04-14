#import "Tweak.h"
#import "NTSManager.h"
#import "NTSNote.h"

static NSString *bundleIdentifier = @"dev.renaitare.notations";

static NSMutableDictionary *preferences;
static BOOL enabled;
static NSInteger gesture;

static BOOL visible;

static void updatePreferences() {

	CFArrayRef preferencesKeyList = CFPreferencesCopyKeyList((CFStringRef)bundleIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if(preferencesKeyList) {

		preferences = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(preferencesKeyList, (CFStringRef)bundleIdentifier, kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(preferencesKeyList);
	}

	else {

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
	}

	else {

		[NTSManager sharedInstance].textSize = [UIFont systemFontSize];
	}

	[[NTSManager sharedInstance] reloadNotes];
}

// Hide notes when locked
static void displayStatusChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[NTSManager sharedInstance].view.hidden = YES;
	visible = NO;
}

// Hide notes on home button press
%hook SBIconController

- (void)handleHomeButtonTap {
	%orig;
	[NTSManager sharedInstance].view.hidden = YES;
	visible = NO;
}

%end

// Hide notes when switcher opens
%hook SBFluidSwitcherViewController

- (void)viewWillAppear:(BOOL)arg1 {
	%orig;
	[NTSManager sharedInstance].view.hidden = YES;
	visible = NO;
}

%end

%hook SBHomeScreenViewController

- (void)viewDidLoad {

	%orig;

	if (enabled == YES) {

		if (gesture == 2) {

			UITapGestureRecognizer *notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNotes)];
			notationsGesture.numberOfTapsRequired = 2;
			[self.view addGestureRecognizer:notationsGesture];
		}

		if (gesture == 3) {

			UITapGestureRecognizer *notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNotes)];
			notationsGesture.numberOfTapsRequired = 3;
			[self.view addGestureRecognizer:notationsGesture];
		}

		[[NTSManager sharedInstance] initView];

		UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(createNote:)];
		[[NTSManager sharedInstance].view addGestureRecognizer:pressRecognizer];

		[self.view addSubview:[NTSManager sharedInstance].view];
		[[NTSManager sharedInstance] loadNotes];
		[[NTSManager sharedInstance] updateNotes];
	}
}

%new
- (void)showNotes {

	if (visible == NO) {

		[NTSManager sharedInstance].view.hidden = NO;
		visible = YES;
	}

	else {

		[NTSManager sharedInstance].view.hidden = YES;
		visible = NO;
	}
}

%new
- (void)createNote:(UILongPressGestureRecognizer *)sender {

	if (sender.state == UIGestureRecognizerStateBegan) {

		if (visible == YES) {

			CGPoint position = [sender locationInView:self.view];

			NTSNote *note = [[NTSNote alloc] init];
			note.text = @"";
			note.x = position.x - 100;
			note.y = position.y - 100;
			note.width = 200;
			note.height = 200;
			note.draggable = YES;
			note.resizeable = YES;

			[[NTSManager sharedInstance] addNote:note];
			[[NTSManager sharedInstance] updateNotes];
		}
	}
}

%end

%hook UIStatusBarWindow

- (instancetype)initWithFrame:(CGRect)frame {

	self = %orig;

	if (gesture == 0) {

		UITapGestureRecognizer *notationsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNotes)];
		notationsGesture.numberOfTapsRequired = 2;
		[self addGestureRecognizer:notationsGesture];
	}

	if (gesture == 1) {

		UILongPressGestureRecognizer *notationsGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showNotes)];
		[self addGestureRecognizer:notationsGesture];
	}

	return self;
}

%new
- (void)showNotes {

	if (visible == NO) {

		[NTSManager sharedInstance].view.hidden = NO;
		visible = YES;
	}

	else {

		[NTSManager sharedInstance].view.hidden = YES;
		visible = NO;
	}
}

%end

%ctor {

	visible = NO;
	updatePreferences();

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, displayStatusChanged, CFSTR("com.apple.iokit.hid.displayStatus"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}