#import <UIKit/UIKit.h>

@class NTSNoteView;

@interface NTSNote : NSObject

@property (nonatomic, retain) NTSNoteView *view;
@property (nonatomic, retain) NSString *text;
@property (nonatomic) NSInteger x;
@property (nonatomic) NSInteger y;
@property (nonatomic) NSInteger cachedX;
@property (nonatomic) NSInteger cachedY;
@property (nonatomic) NSInteger width;
@property (nonatomic) NSInteger height;
@property (nonatomic) BOOL draggable;
@property (nonatomic) BOOL resizeable;
@property (nonatomic) BOOL presented;

- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;
- (void)setupView;
- (void)willShowView;
- (void)willHideView;
- (void)didShowView;
- (void)keyboardDidShow;
- (void)keyboardDidHide;

@end
