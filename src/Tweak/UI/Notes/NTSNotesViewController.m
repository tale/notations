#import "NTSNotesViewController.h"
#import "../../Manager/NTSManager.h"
#import "../Window/NTSWindow.h"
#import <UIKit/UIKit+Private.h>

@implementation NTSNotesViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.userInteractionEnabled = YES;

	// Blurry background view
	self.effectView = [[UIVisualEffectView alloc] init];
	self.effectView.frame = self.view.bounds;
	self.effectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:self.effectView];

	// Gestures
	UILongPressGestureRecognizer *pressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:[NTSManager sharedInstance] action:@selector(createNote:)];
	[self.view addGestureRecognizer:pressRecognizer];

	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:[NTSManager sharedInstance] action:@selector(hideNotes)];
	[self.view addGestureRecognizer:tapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self present];
}

- (void)present {
	// Background effects
	UIBlurEffect *blurEffect = [UIBlurEffect effectWithBlurRadius:10];
	_UIZoomEffect *zoomEffect = [NSClassFromString(@"_UIZoomEffect") _underlayZoomEffectWithMagnitude:0.024];
	_UIOverlayEffect *overlayEffect = [[NSClassFromString(@"_UIOverlayEffect") alloc] init];
	overlayEffect.filterType = @"multiplyBlendMode";
	overlayEffect.color = [UIColor blackColor];
	overlayEffect.alpha = 0.088;

	[UIView animateWithDuration:0.2 animations:^{
		self.effectView.backgroundEffects = @[zoomEffect, overlayEffect, blurEffect];
		self.effectView.backgroundColor = [UIColor colorWithRed:0.086 green:0.082 blue:0.1647 alpha:0.21];
	} completion:nil];
}

- (void)dismiss {
	CABasicAnimation *colorAnimation = [CABasicAnimation animation];
	colorAnimation.keyPath = @"backgroundColor";
	colorAnimation.fromValue = (id)[UIColor colorWithRed:0.086 green:0.082 blue:0.1647 alpha:0.21].CGColor;
	colorAnimation.toValue = (id)[UIColor clearColor].CGColor;
	colorAnimation.duration = 0.3;

	[self.effectView.layer addAnimation:colorAnimation forKey:@"backgroundColor"];

	[UIView animateWithDuration:0.2 animations:^{
		self.effectView.backgroundEffects = nil;
	} completion:nil];
}

- (BOOL)_canShowWhileLocked {
	return YES;
}

@end
