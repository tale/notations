#import "NTSNotesViewController.h"
#import "../../Manager/NTSManager.h"
#import "../Window/NTSWindow.h"
#import "../Popup/NTSCreateNotePopupViewController.h"
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

	// "Notes" title
	self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 40, 0, 0)];
	self.titleLabel.alpha = 0;
	self.titleLabel.text = @"Notes";
	self.titleLabel.font = [UIFont boldSystemFontOfSize:42.0];
	[self.titleLabel sizeToFit];
	[self.view addSubview:self.titleLabel];

	// Create note button
	self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.addButton.alpha = 0;
	self.addButton.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
	self.addButton.layer.cornerRadius = 30;
	self.addButton.translatesAutoresizingMaskIntoConstraints = NO;
	[self.addButton addTarget:self action:@selector(openCreateNotePopup) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.addButton];
	
	[self.addButton.widthAnchor constraintEqualToConstant:60].active = YES;
	[self.addButton.heightAnchor constraintEqualToConstant:60].active = YES;
	[self.addButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-30].active = YES;
	[self.addButton.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:-30].active = YES;

	// + button text
	// TODO: make this look good
	self.addLabel = [[UILabel alloc] init];
	self.addLabel.text = @"+";
	self.addLabel.textColor = [UIColor whiteColor];
    self.addLabel.textAlignment = NSTextAlignmentCenter;
	self.addLabel.font = [UIFont boldSystemFontOfSize:32.0];
	self.addLabel.frame = CGRectMake(0, -2.5, 60, 60);
	[self.addButton addSubview:self.addLabel];

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
	// no clue what this does
	// CABasicAnimation *animation = [CABasicAnimation animation];
	// animation.keyPath = @"uiFractionalProgress";
	// animation.fromValue = @0;
	// animation.toValue = @100;
	// animation.duration = 1.0;

	// Background darkening
	// CABasicAnimation *colorAnimation = [CABasicAnimation animation];
	// colorAnimation.keyPath = @"backgroundColor";
	// colorAnimation.fromValue = (id)[UIColor clearColor].CGColor;
	// colorAnimation.toValue = (id)[UIColor colorWithRed:0.086 green:0.082 blue:0.1647 alpha:0.21].CGColor;
	// colorAnimation.duration = 0.2;
	
	//[self.effectView.layer addAnimation:animation forKey:@"UIPacingAnimationForAnimatorsKey"];
	//[self.effectView.layer addAnimation:colorAnimation forKey:@"backgroundColor"];

	// Background effects
	UIBlurEffect *blurEffect = [UIBlurEffect effectWithBlurRadius:10];
	_UIZoomEffect *zoomEffect = [NSClassFromString(@"_UIZoomEffect") _underlayZoomEffectWithMagnitude:0.024];
	_UIOverlayEffect *overlayEffect = [[NSClassFromString(@"_UIOverlayEffect") alloc] init];
	overlayEffect.filterType = @"multiplyBlendMode";
	overlayEffect.color = [UIColor blackColor];
	overlayEffect.alpha = 0.088;

	[UIView animateWithDuration:0.2 animations:^{
		//self.titleLabel.alpha = 1;
		//self.addButton.alpha = 1;
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
		//self.titleLabel.alpha = 0;
		//self.addButton.alpha = 0;
		self.effectView.backgroundEffects = nil;
	} completion:nil];
}

- (void)openCreateNotePopup {
	NTSCreateNotePopupViewController *popupViewController = [[NTSCreateNotePopupViewController alloc] init];
	popupViewController.transitioningDelegate = popupViewController;
	popupViewController.modalPresentationStyle = UIModalPresentationCustom;

	[[NTSManager sharedInstance].window.rootViewController presentViewController:popupViewController animated:YES completion:nil];
}

- (BOOL)_canShowWhileLocked {
	return YES;
}

@end
