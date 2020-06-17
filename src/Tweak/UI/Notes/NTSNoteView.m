#import "NTSNoteView.h"
#import "../../Manager/NTSManager.h"
// #import "../../../Tweak.h"

@implementation NTSNoteView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];

	if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = YES;
		self.layer.cornerRadius = 20;

		// Background blur
		UIBlurEffect *blurEffect;

		if ([NTSManager sharedInstance].colorStyle == 0) {
			if (@available(iOS 13, *)) {
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

		// Buttons
		UIColor *buttonColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];

		self.lockButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.lockButton.backgroundColor = buttonColor;
		self.lockButton.layer.cornerRadius = 15.0;
		self.lockButton.translatesAutoresizingMaskIntoConstraints = NO;
		[self.lockButton setImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Notations/unlocked.png"] forState:UIControlStateNormal];
		[self addSubview:self.lockButton];

		[self.lockButton.widthAnchor constraintEqualToConstant:30].active = YES;
		[self.lockButton.heightAnchor constraintEqualToConstant:30].active = YES;
		[self.lockButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:5].active = YES;
		[self.lockButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:5].active = YES;

		self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.deleteButton.backgroundColor = buttonColor;
		self.deleteButton.layer.cornerRadius = 15.0;
		self.deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
		[self.deleteButton setImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Notations/delete.png"] forState:UIControlStateNormal];
		[self addSubview:self.deleteButton];

		[self.deleteButton.widthAnchor constraintEqualToConstant:30].active = YES;
		[self.deleteButton.heightAnchor constraintEqualToConstant:30].active = YES;
		[self.deleteButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:5].active = YES;
		[self.deleteButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5].active = YES;

		self.resizeGrabber = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
		UIImageView *resizeImage = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Notations/resize.png"]];
		resizeImage.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |  UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);

		self.resizeGrabber.backgroundColor = buttonColor;
		self.resizeGrabber.layer.cornerRadius = 15.0;
		self.resizeGrabber.translatesAutoresizingMaskIntoConstraints = NO;
		[self.resizeGrabber addSubview:resizeImage];
		[self addSubview:self.resizeGrabber];

		[self.resizeGrabber.widthAnchor constraintEqualToConstant:30].active = YES;
		[self.resizeGrabber.heightAnchor constraintEqualToConstant:30].active = YES;
		[self.resizeGrabber.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-5].active = YES;
		[self.resizeGrabber.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-5].active = YES;

		UIPanGestureRecognizer *dragResize = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(resizeView:)];
		[self.resizeGrabber addGestureRecognizer:dragResize];

		// Text view
		self.textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 50, self.frame.size.width - 20, self.frame.size.height - 80)];
		self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.textView.backgroundColor = [UIColor clearColor];
		self.textView.font = [UIFont systemFontOfSize:[NTSManager sharedInstance].textSize];

		if ([NTSManager sharedInstance].textAlignment == 1) {
			self.textView.textAlignment = NSTextAlignmentLeft;
		} else if ([NTSManager sharedInstance].textAlignment == 2) {
			self.textView.textAlignment = NSTextAlignmentCenter;
		} else if ([NTSManager sharedInstance].textAlignment == 3) {
			self.textView.textAlignment = NSTextAlignmentRight;
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
		if (@available(iOS 13, *)) {
			self.textView.textColor = [UIColor labelColor];
			blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
		} else {
			self.textView.textColor = [UIColor blackColor];
			blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
		}
	} else if ([NTSManager sharedInstance].colorStyle == 2) {
		self.textView.textColor = [UIColor whiteColor];
		blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
	} else {
		self.textView.textColor = [UIColor blackColor];
		blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
	}

	self.blurEffectView.effect = blurEffect;

	self.textView.font = [UIFont systemFontOfSize:[NTSManager sharedInstance].textSize];
	if ([NTSManager sharedInstance].textAlignment == 1) {
		self.textView.textAlignment = NSTextAlignmentLeft;
	} else if ([NTSManager sharedInstance].textAlignment == 2) {
		self.textView.textAlignment = NSTextAlignmentCenter;
	} else if ([NTSManager sharedInstance].textAlignment == 3) {
		self.textView.textAlignment = NSTextAlignmentRight;
	} else {
		self.textView.textAlignment = NSTextAlignmentNatural;
	}
}

- (void)setHidden:(BOOL)hidden {
	if (!hidden) {
		self.transform = CGAffineTransformMakeScale(0, 0);
		[super setHidden:hidden];
		[UIView animateWithDuration:0.2 animations:^{
			self.transform = CGAffineTransformMakeScale(1, 1);
		} completion:nil];
	} else {
		self.transform = CGAffineTransformMakeScale(1, 1);
		[UIView animateWithDuration:0.2 animations:^{
			self.transform = CGAffineTransformMakeScale(0.01, 0.01); // Not possible to animate scale to 0
		} completion:^(BOOL finished) {
			[super setHidden:hidden];
			[self removeFromSuperview];
		}];
	}
}

- (void)lockNote {
	[UIView animateWithDuration:0.2 animations:^{
		self.resizeGrabber.alpha = 0;
		self.deleteButton.alpha = 0;
		self.textView.frame = CGRectMake(20, 50, self.frame.size.width - 20, self.frame.size.height - 50);
	} completion:nil];
}

- (void)unlockNote {
	[UIView animateWithDuration:0.2 animations:^{
		self.resizeGrabber.alpha = 1;
		self.deleteButton.alpha = 1;
		self.textView.frame = CGRectMake(20, 50, self.frame.size.width - 20, self.frame.size.height - 80);
	} completion:nil];
}

- (void)resizeView:(UIPanGestureRecognizer *)gesture {
	CGPoint translatedPoint = [gesture translationInView:gesture.view];
	[gesture setTranslation:CGPointZero inView:gesture.view];

	CGFloat x = self.frame.origin.x;
	CGFloat y = self.frame.origin.y;
	CGFloat width = self.frame.size.width;
	CGFloat height = self.frame.size.height;

	CGFloat minHeight = 200;
	CGFloat minWidth = 200;

	if (height + translatedPoint.y <= minHeight) height = minHeight - translatedPoint.y;
	if (width+translatedPoint.x <= minWidth) width = minWidth - translatedPoint.x;
	self.frame = CGRectMake(x, y, width + translatedPoint.x, height + translatedPoint.y);
}

@end
