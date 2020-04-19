#import <UIKit/UIKit.h>

@interface NTSPopupViewController : UIViewController <UIViewControllerTransitioningDelegate>

@property (nonatomic, retain) UIButton *closeButton;

- (void)dismiss;

@end
