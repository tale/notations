#import "NTSPopupView.h"
#import "../../Manager/NTSManager.h"
#import "../../Objects/NTSNote.h"
#import "../../../Tweak.h"

@implementation NTSPopupView

- (instancetype)initWithFrame:(CGRect)frame withNote:(NTSNote *)note {
	self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];

	if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = YES;
		self.layer.cornerRadius = 20;
		self.cachedNote = note;

		// Blur Background
		UIBlurEffect *blurEffect;

		if ([NTSManager sharedInstance].colorStyle == 0) {
			if (SYSTEM_VERSION(@"13.0")) {
				blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
			} else {
				blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
			}
		} else if ([NTSManager sharedInstance].colorStyle == 2) {
			blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
		} else {
			blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
		}

		self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
		self.blurEffectView.layer.cornerRadius = 20;
		self.blurEffectView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
		self.blurEffectView.layer.masksToBounds = YES;
		self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:self.blurEffectView];

		// Button
		UIColor *buttonColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];

		self.actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.actionButton.backgroundColor = buttonColor;
		self.actionButton.layer.cornerRadius = 15.0;
		self.actionButton.translatesAutoresizingMaskIntoConstraints = NO;
		self.actionButton.userInteractionEnabled = YES;
		[self.actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[self.actionButton setTitle:@"Undo" forState:UIControlStateNormal];
		[self.actionButton addTarget:self action:@selector(restoreNote) forControlEvents:UIControlEventTouchUpInside];

		[self addSubview:self.actionButton];
		[self.actionButton.widthAnchor constraintEqualToConstant:120].active = YES;
		[self.actionButton.heightAnchor constraintEqualToAnchor:self.heightAnchor constant:-10].active = YES;
		[self.actionButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:5].active = YES;
		[self.actionButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:5].active = YES;
	}

	return self;
}

- (void)restoreNote {
	[[NTSManager sharedInstance] addNote:self.cachedNote];
}

@end
