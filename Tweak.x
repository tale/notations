#import "Tweak.h"

@interface SBHomeScreenViewController : UIViewController
@end

@interface UIStatusBarWindow : UIWindow
@end

static NSString *bundleIdentifier = @"dev.renaitare.notations";


static NSMutableDictionary *preferences;
static BOOL enabled;

BOOL visible;

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
	[NTSManager sharedInstance].colorStyle = [([preferences objectForKey:@"style"] ?: @(0)) integerValue];
	[NTSManager sharedInstance].useCustomTextSize = [([preferences objectForKey:@"useCustomTextSize"] ?: @(NO)) boolValue];

	if ([NTSManager sharedInstance].useCustomTextSize == YES) {

		[NTSManager sharedInstance].textSize = [([preferences objectForKey:@"customTextSize"] ?: @(14)) integerValue];
	}

    else {

        [NTSManager sharedInstance].textSize = [UIFont systemFontSize];
    }

    [[NTSManager sharedInstance] reloadNotes];
}

%hook SBHomeScreenViewController

- (void)viewDidLoad {

    %orig;
	
    if (enabled == YES) {

        UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(createNote:)];
        [self.view addGestureRecognizer:pressRecognizer];

        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNotes:)];
        tapRecognizer.numberOfTapsRequired = 2;

        [self.view addGestureRecognizer:tapRecognizer];


        [[NTSManager sharedInstance] initView];
        [self.view addSubview:[NTSManager sharedInstance].view];
        [[NTSManager sharedInstance] loadNotes];
        [[NTSManager sharedInstance] updateNotes];
    }
}

%new
- (void)showNotes:(UITapGestureRecognizer *)sender {

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
            note.text = note.textView.text;
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

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNotes:)];
    tapRecognizer.numberOfTapsRequired = 2;

    [self addGestureRecognizer:tapRecognizer];

    return self;
}

%new
- (void)showNotes:(UITapGestureRecognizer *)sender {

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
}