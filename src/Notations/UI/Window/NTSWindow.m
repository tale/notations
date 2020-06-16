#import "NTSWindow.h"
#import "../../Manager/NTSManager.h"
#import "../Notes/NTSNotesViewController.h"

@implementation NTSWindow : UIWindow

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		self.rootViewController = [[NTSNotesViewController alloc] init];
	}

	return self;
}

- (void)setHidden:(BOOL)hidden {
	if (![self.rootViewController isKindOfClass:[NTSNotesViewController class]]) {
		self.rootViewController = [[NTSNotesViewController alloc] init];
	}

	if (!hidden) {
		[super setHidden:hidden];
		[(NTSNotesViewController *)self.rootViewController present];
	} else {
		[(NTSNotesViewController *)self.rootViewController dismiss];
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
