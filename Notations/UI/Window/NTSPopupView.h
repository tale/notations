#import <UIKit/UIKit.h>
#import "../../Objects/NTSNote.h"

@interface NTSPopupView : UIView

@property (nonatomic, retain) UIVisualEffectView *blurEffectView;
@property (nonatomic, retain) UITextView *infoTextView;
@property (nonatomic, retain) UIButton *actionButton;
@property (nonatomic, retain) NTSNote *cachedNote;

- (instancetype)initWithFrame:(CGRect)frame withNote:(NTSNote *)note;
- (void)restoreNote;

@end
