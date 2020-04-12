#import <UIKit/UIKit.h>

@class NTSNote;
@interface NTSManager : NSObject

@property(nonatomic, retain) UIView *view;
@property(nonatomic, retain) NSMutableArray<NTSNote *> *notes;

+ (instancetype)sharedInstance;
- (id)init;
- (void)initView;
- (void)addNote:(NTSNote *)note;
- (void)removeNote:(NTSNote *)note;
- (void)loadNotes;
- (void)updateNotes;

@end