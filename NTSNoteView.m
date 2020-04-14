#import "NTSNoteView.h"
#import "NTSManager.h"
#import "Tweak.h"

@implementation NTSNoteView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = YES;
		self.layer.cornerRadius = 20;

		// Background blur
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
		self.blurEffectView.frame = self.bounds;
		self.blurEffectView.layer.masksToBounds = YES;
		self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

		[self addSubview:self.blurEffectView];

		// Buttons
		UIColor *buttonColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];

		self.lockButton = [UIButton buttonWithType:UIButtonTypeCustom];

		self.lockButton.frame = CGRectMake(5, 5, 30, 30);
		self.lockButton.layer.cornerRadius = 15.0;
		[self.lockButton setImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Notations/unlocked.png"] forState:UIControlStateNormal];
		[self.lockButton setBackgroundColor:buttonColor];

		[self addSubview:self.lockButton];

		self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];

		self.deleteButton.frame = CGRectMake(frame.size.width - 35, 5, 30, 30);
		self.deleteButton.layer.cornerRadius = 15.0;
		[self.deleteButton setImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Notations/delete.png"] forState:UIControlStateNormal];
		[self.deleteButton setBackgroundColor:buttonColor];

		[self addSubview:self.deleteButton];

		// Text view
		self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 50, frame.size.width - 20, frame.size.height - 60)];

		self.textView.backgroundColor = [UIColor clearColor];
		self.textView.font = [UIFont systemFontOfSize:[NTSManager sharedInstance].textSize];

		if ([NTSManager sharedInstance].textAlignment == 1) {
			self.textView.textAlignment = NSTextAlignmentLeft;
		} else if ([NTSManager sharedInstance].textAlignment == 2) {
			self.textView.textAlignment = NSTextAlignmentCenter;
		} else if ([NTSManager sharedInstance].textAlignment == 3) {
			self.textView.textAlignment = NSTextAlignmentRight;
		} else if ([NTSManager sharedInstance].textAlignment == 4) {
			self.textView.textAlignment = NSTextAlignmentJustified;
		} else {
			self.textView.textAlignment = NSTextAlignmentNatural;
		}

		[self addSubview:self.textView];
	}

	return self;
}

- (void)updateEffect {
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

	self.blurEffectView.effect = blurEffect;
}

- (void)setHidden:(BOOL)hidden {
	if (!hidden) {
		self.transform = CGAffineTransformMakeScale(0, 0);
		[super setHidden:hidden];
		[UIView animateWithDuration:0.3 animations:^{
			self.transform = CGAffineTransformMakeScale(1, 1);
		} completion:nil];
	} else {
		self.transform = CGAffineTransformMakeScale(1, 1);
		[UIView animateWithDuration:0.3 animations:^{
			self.transform = CGAffineTransformMakeScale(0.01, 0.01); // Not possible to animate scale to 0
		} completion:^(BOOL finished) {
			[super setHidden:hidden];
			[self removeFromSuperview];
		}];
	}
}

@end
