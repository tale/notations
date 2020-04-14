#import "NTSWindow.h"
#import "NTSManager.h"

@implementation NTSWindow : UIWindow

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		//self.backgroundColor = [UIColor redColor];
		[self addSubview:[NTSManager sharedInstance].notesView];
		[NTSManager sharedInstance].notesView.hidden = NO;
	}

	return self;
}

- (void)setHidden:(BOOL)hidden {
	if (!hidden) {
		[NTSManager sharedInstance].notesView.alpha = 0;
		[super setHidden:hidden];
		[UIView animateWithDuration:0.3 animations:^{
			[NTSManager sharedInstance].notesView.alpha = 1;
		} completion:nil];
	} else {
		[UIView animateWithDuration:0.3 animations:^{
			[NTSManager sharedInstance].notesView.alpha = 0;
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
