#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class RINotationsNoteView;

@interface RINotationsNote : NSObject <NSCoding>

@property (nonatomic, retain) RINotationsNoteView *view;
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
