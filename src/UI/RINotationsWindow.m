#import "./RINotationsWindow.h"
#import "./RINotationsViewController.h"
#import "../Objects/RINotationsManager.h"

@implementation RINotationsWindow

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		self.rootViewController = [[RINotationsViewController alloc] init];
	}

	return self;
}

- (void)setHidden:(BOOL)hidden {
	if (![self.rootViewController isKindOfClass:[RINotationsViewController class]]) {
		self.rootViewController = [[RINotationsViewController alloc] init];
	}

	if (!hidden) {
		[super setHidden:hidden];
		[(RINotationsViewController *)self.rootViewController present];
	} else {
		[(RINotationsViewController *)self.rootViewController dismiss];
		self.backgroundColor = nil;
		[UIView animateWithDuration:0.2 animations:^{
			self.backgroundColor = [UIColor clearColor];
		} completion:^(BOOL finished) {
			[super setHidden:hidden];
		}];
	}
}

- (BOOL)_canShowWhileLocked {
	return YES;
}

- (BOOL)_shouldCreateContextAsSecure {
    return YES;
}

@end
