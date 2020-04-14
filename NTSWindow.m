#import "NTSWindow.h"
#import "NTSManager.h"

@implementation NTSWindow : UIWindow

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		//self.backgroundColor = [UIColor redColor];
		[self addSubview:[NTSManager sharedInstance].view];
		[NTSManager sharedInstance].view.hidden = NO;
	}

	return self;
}

- (BOOL)_canShowWhileLocked {
	return YES;
}

- (BOOL)_shouldCreateContextAsSecure {
    return YES;
}

@end
