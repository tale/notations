#import <UIKit/UIKit.h>
#import "NTSManager.h"

@interface NTSNote : NSObject

@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) UITextView *textView;
@property (nonatomic, retain) NSString *text;
@property (nonatomic) NSInteger x;
@property (nonatomic) NSInteger y;
@property (nonatomic) NSInteger width;
@property (nonatomic) NSInteger height;
@property (nonatomic) BOOL draggable;
@property (nonatomic) BOOL resizeable;

- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;
- (void)setupView;

@end

@interface MTMaterialView : UIView
@end