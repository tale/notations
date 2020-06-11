#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class RINotationsNote, RINotationsWindow, RINotationsView;

@interface RINotationsManager : NSObject

@property (nonatomic, retain) NSMutableArray<RINotationsNote *> *notes;
@property (nonatomic, retain) RINotationsWindow *window;
@property (nonatomic, retain) UIView *view;
@property (nonatomic) BOOL visible;

@property (nonatomic) BOOL enabled;
@property (nonatomic) NSInteger gesture;
@property (nonatomic) NSInteger style;
@property (nonatomic) NSInteger alignment;

+ (instancetype)sharedInstance;
- (instancetype)init;
- (void)loadView;
- (void)createNote:(UILongPressGestureRecognizer *)sender;
- (void)removeNote:(RINotationsNote *)note;
- (void)loadNotes;
- (void)reloadNotes;
- (void)toggleNotes;
- (void)showNotes;
- (void)hideNotes;

@end

