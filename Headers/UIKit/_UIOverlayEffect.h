#import <UIKit/UIVisualEffect.h>

@interface _UIOverlayEffect : UIVisualEffect

@property (nonatomic, copy) NSString *filterType;
@property (nonatomic, copy) UIColor *color;
@property (nonatomic, assign) double alpha;

@end
