#import <UIKit/UIKit.h>

@class NTSNote, NTSWindow, NTSNotesView;

@interface NTSManager : NSObject

@property (nonatomic, retain) UIView *notesView;
@property (nonatomic, retain) NSMutableArray<NTSNote *> *notes;
@property (nonatomic, retain) NTSWindow *window;
@property (nonatomic) BOOL windowVisible;
@property (nonatomic) BOOL enabled;
@property (nonatomic) BOOL isCustomText;
@property (nonatomic) NSInteger textSize;
@property (nonatomic) NSInteger textAlignment;
@property (nonatomic) NSInteger colorStyle;

+ (instancetype)sharedInstance;
- (id)init;
- (void)loadView;
- (void)removeNote:(NTSNote *)note;
- (void)createNote:(UILongPressGestureRecognizer *)sender;
- (void)loadNotes;
- (void)updateNotes;
- (void)toggleNotesShown;
- (void)showNotes;
- (void)hideNotes;

@end
