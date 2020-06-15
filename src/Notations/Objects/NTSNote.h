#import <UIKit/UIKit.h>

@class NTSNoteView;

@interface NTSNote : NSObject <NSCoding>

@property (nonatomic, retain) NTSNoteView *view;
@property (nonatomic, retain) NSString *text;
@property (nonatomic) CGPoint center;
@property (nonatomic) CGSize size;
@property (nonatomic) BOOL presented;
@property (nonatomic) BOOL interactive;

- (instancetype)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;
- (void)loadView;
- (void)willShowView;
- (void)willHideView;
- (void)didShowView;

@end
