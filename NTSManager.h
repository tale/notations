#import <UIKit/UIKit.h>

@class NTSNote;
@interface NTSManager : NSObject

@property(nonatomic, retain) UIView *view;
@property(nonatomic, retain) NSMutableArray<NTSNote *> *notes;
@property(nonatomic) BOOL useCustomTextSize;
@property(nonatomic) NSInteger textSize;
@property(nonatomic) NSInteger colorStyle;

+ (instancetype)sharedInstance;
- (id)init;
- (void)initView;
- (void)addNote:(NTSNote *)note;
- (void)removeNote:(NTSNote *)note;
- (void)loadNotes;
- (void)reloadNotes;
- (void)updateNotes;

@end