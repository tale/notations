#import "NTSNoteView.h"
#import "../../Manager/NTSManager.h"
#import "../../../Tweak.h"

@implementation NTSNoteView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width + 20, frame.size.height + 20)];

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
		self.blurEffectView.frame = CGRectMake(10, 10, self.bounds.size.width - 20, self.bounds.size.height - 20);
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
		[self.lockButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:15].active = YES;
		[self.lockButton.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:15].active = YES;

		self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.deleteButton.backgroundColor = buttonColor;
		self.deleteButton.layer.cornerRadius = 15.0;
		self.deleteButton.translatesAutoresizingMaskIntoConstraints = NO;
		[self.deleteButton setImage:[[UIImage alloc] initWithContentsOfFile:@"/Library/Application Support/Notations/delete.png"] forState:UIControlStateNormal];
		[self addSubview:self.deleteButton];

		[self.deleteButton.widthAnchor constraintEqualToConstant:30].active = YES;
		[self.deleteButton.heightAnchor constraintEqualToConstant:30].active = YES;
		[self.deleteButton.topAnchor constraintEqualToAnchor:self.topAnchor constant:15].active = YES;
		[self.deleteButton.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-15].active = YES;

		// Text view
		self.textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 50, frame.size.width - 20, frame.size.height - 50)];
		self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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

		// Resizing grabbers
		self.resizingViewsContainer = [[UIView alloc] initWithFrame:self.bounds];
		[self insertSubview:self.resizingViewsContainer atIndex:0];

		UIView *bottomGrabber = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 5)];
		bottomGrabber.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
		bottomGrabber.clipsToBounds = YES;
		bottomGrabber.layer.cornerRadius = 2.5;
		bottomGrabber.translatesAutoresizingMaskIntoConstraints = NO;
		[self.resizingViewsContainer addSubview:bottomGrabber];

		[bottomGrabber.widthAnchor constraintEqualToConstant:40].active = YES;
		[bottomGrabber.heightAnchor constraintEqualToConstant:5].active = YES;
		[bottomGrabber.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
		[bottomGrabber.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;

		UIView *leftGrabber = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 40)];
		leftGrabber.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
		leftGrabber.clipsToBounds = YES;
		leftGrabber.layer.cornerRadius = 2.5;
		leftGrabber.translatesAutoresizingMaskIntoConstraints = NO;
		[self.resizingViewsContainer addSubview:leftGrabber];

		[leftGrabber.widthAnchor constraintEqualToConstant:5].active = YES;
		[leftGrabber.heightAnchor constraintEqualToConstant:40].active = YES;
		[leftGrabber.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
		[leftGrabber.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;

		UIView *rightGrabber = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 40)];
		rightGrabber.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
		rightGrabber.clipsToBounds = YES;
		rightGrabber.layer.cornerRadius = 2.5;
		rightGrabber.translatesAutoresizingMaskIntoConstraints = NO;
		[self.resizingViewsContainer addSubview:rightGrabber];

		[rightGrabber.widthAnchor constraintEqualToConstant:5].active = YES;
		[rightGrabber.heightAnchor constraintEqualToConstant:40].active = YES;
		[rightGrabber.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;
		[rightGrabber.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;

		// Resizing views
		UIView *bottomGrabberView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 15)];
		bottomGrabberView.translatesAutoresizingMaskIntoConstraints = NO;
		bottomGrabberView.userInteractionEnabled = YES;
		bottomGrabberView.tag = 1;
		[self.resizingViewsContainer addSubview:bottomGrabberView];

		[bottomGrabberView.widthAnchor constraintEqualToAnchor:self.widthAnchor].active = YES;
		[bottomGrabberView.heightAnchor constraintEqualToConstant:15].active = YES;
		[bottomGrabberView.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = YES;
		[bottomGrabberView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;

		UIView *rightGrabberView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 200)];
		rightGrabberView.translatesAutoresizingMaskIntoConstraints = NO;
		rightGrabberView.userInteractionEnabled = YES;
		rightGrabberView.tag = 2;
		[self.resizingViewsContainer addSubview:rightGrabberView];

		[rightGrabberView.widthAnchor constraintEqualToConstant:15].active = YES;
		[rightGrabberView.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
		[rightGrabberView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
		[rightGrabberView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;

		UIView *leftGrabberView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 200)];
		leftGrabberView.translatesAutoresizingMaskIntoConstraints = NO;
		leftGrabberView.userInteractionEnabled = YES;
		leftGrabberView.tag = 3;
		[self.resizingViewsContainer addSubview:leftGrabberView];

		[leftGrabberView.widthAnchor constraintEqualToConstant:15].active = YES;
		[leftGrabberView.heightAnchor constraintEqualToAnchor:self.heightAnchor].active = YES;
		[leftGrabberView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
		[leftGrabberView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor].active = YES;

		UIPanGestureRecognizer *dragDown = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(resizeView:)];
		[bottomGrabberView addGestureRecognizer:dragDown];
		UIPanGestureRecognizer *dragRight = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(resizeView:)];
		[rightGrabberView addGestureRecognizer:dragRight];
		UIPanGestureRecognizer *dragLeft = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(resizeView:)];
		[leftGrabberView addGestureRecognizer:dragLeft];
	}

	return self;
}

- (void)updateEffect {
	UIBlurEffect *blurEffect;

	if ([NTSManager sharedInstance].colorStyle == 0) {
		if (SYSTEM_VERSION(@"13.0")) {
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
	} else if ([NTSManager sharedInstance].textAlignment == 4) {
		self.textView.textAlignment = NSTextAlignmentJustified;
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

- (void)hideGrabbers {
	[UIView animateWithDuration:0.2 animations:^{
		self.resizingViewsContainer.alpha = 0;
	} completion:nil];
}

- (void)showGrabbers {
	[UIView animateWithDuration:0.2 animations:^{
		self.resizingViewsContainer.alpha = 1;
	} completion:nil];
}

- (void)resizeView:(UIPanGestureRecognizer *)gesture {
	CGPoint translatedPoint = [gesture translationInView:gesture.view];
	[gesture setTranslation:CGPointZero inView:gesture.view];

	CGFloat x = self.frame.origin.x;
	CGFloat y = self.frame.origin.y;
	CGFloat width = self.frame.size.width;
	CGFloat height = self.frame.size.height;

	CGFloat minHeight = 220;
	CGFloat minWidth = 220;

	if (gesture.view.tag == 1) {
		if (height+translatedPoint.y <= minHeight) height = minHeight - translatedPoint.y;
		self.frame = CGRectMake(x, y, width, height+translatedPoint.y);
	} else if (gesture.view.tag == 2) {
		if (width+translatedPoint.x <= minWidth) width = minWidth - translatedPoint.x;
		self.frame = CGRectMake(x, y, width+translatedPoint.x, height);
	} else if (gesture.view.tag == 3) {
		if (width-translatedPoint.x <= minWidth) translatedPoint.x = width - minWidth;
		self.frame = CGRectMake(x+translatedPoint.x, y, width-translatedPoint.x, height);
	}
}

@end
