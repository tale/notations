#import "NTSPopupPresentationController.h"

@implementation NTSPopupPresentationController

- (CGRect)frameOfPresentedViewInContainerView {
    CGRect result = self.containerView.frame;

    CGFloat height = result.size.height/2;
    result.origin.y = height;
    result.size.height = height - 6;
	result.size.width = result.size.width - 12;
	result.origin.x = 6;

    return result;
}

- (void)presentationTransitionWillBegin {
	self.dimmingView = [[UIView alloc] initWithFrame:self.containerView.frame];
	self.dimmingView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];

	self.dimmingView.alpha = 0;
	[self.containerView insertSubview:self.dimmingView atIndex:0];

	[self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		self.dimmingView.alpha = 1;
	} completion:nil];
}

- (void)dismissalTransitionWillBegin {
	[super dismissalTransitionWillBegin];

	[self.presentingViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		self.dimmingView.alpha = 0;
	} completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
	if (!completed) {
		[self.dimmingView removeFromSuperview];
	}
}

@end
