#import <UIKit/UIKit.h>

@interface NTSNotesViewController : UIViewController

@property (nonatomic, retain) UIVisualEffectView *effectView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UIButton *addButton;
@property (nonatomic, retain) UILabel *addLabel;

- (void)present;
- (void)dismiss;

@end
