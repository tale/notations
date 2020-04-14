#import <UIKit/UIKit.h>

@class NTSNote, NTSWindow;

@interface NTSManager : NSObject

@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) NSMutableArray<NTSNote *> *notes;
@property (nonatomic, retain) NTSWindow *window;
@property (nonatomic) BOOL windowVisible;
@property (nonatomic) BOOL useCustomTextSize;
@property (nonatomic) NSInteger textSize;
@property (nonatomic) NSInteger textAlignment;
@property (nonatomic) NSInteger colorStyle;

+ (instancetype)sharedInstance;
- (id)init;
- (void)initView;
- (void)addNote:(NTSNote *)note;
- (void)removeNote:(NTSNote *)note;
- (void)createNote:(CGPoint)position;
- (void)loadNotes;
- (void)reloadNotes;
- (void)updateNotes;
- (void)toggleNotes;
- (void)showNotes;
- (void)hideNotes;

@end