#import <UIKit/UIVisualEffect.h>

@interface _UIZoomEffect : UIVisualEffect

+ (id)zoomEffectWithMagnitude:(double)magnitude;
+ (id)_underlayZoomEffectWithMagnitude:(double)magnitude;

@end
