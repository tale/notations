#import <UIKit/UIKit.h>

@interface NTSNoteView : UIView

@property (nonatomic, retain) UIVisualEffectView *blurEffectView;
@property (nonatomic, retain) UIView *resizeGrabber;
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) UIButton *lockButton;
@property (nonatomic, retain) UIButton *deleteButton;

- (void)updateEffect;
- (void)lockNote;
- (void)unlockNote;

@end
