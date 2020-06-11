#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RINotationsViewController : UIViewController

@property (nonatomic, retain) UIVisualEffectView *effectView;
@property (nonatomic, retain) UILabel *titleLabel;

- (void)present;
- (void)dismiss;

@end
