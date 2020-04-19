#import "NTSPopupViewController.h"
#import "NTSPopupPresentationController.h"

@implementation NTSPopupViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	self.view.backgroundColor = [UIColor whiteColor];
	self.view.layer.cornerRadius = 12.5;

	// x button
	self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	self.closeButton.frame = CGRectMake(self.view.bounds.size.width - 50, 20, 24, 24);
	self.closeButton.backgroundColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.95 alpha:1.0];
	self.closeButton.layer.cornerRadius = 12.0;
	[self.closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:self.closeButton];
}

- (void)dismiss {
	[self dismissViewControllerAnimated:YES completion:nil];
}

// UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
	return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
	return nil;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
	return [[NTSPopupPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
	return nil;
}

- (BOOL)_canShowWhileLocked {
	return YES;
}

@end
